# == Class: simplib::secure_mountpoints
#
# This class adds security settings to several mounts on the system.
#
# === Parameters
#
# [*secure_tmp_mounts*]
#   Accepts: Boolean
#   Default: true
#   If set to <tt>true</tt>:
#   * Set noexec,nosuid,nodev on temp directories as appropriate and bind mount
#     /var/tmp to /tmp.
#   * If /tmp is *not* a separate partition, then it will be bind mounted to
#     itself with the modified settings.
#   If set to <tt>false</tt>:
#   * Do not manage the temp directories.
#
#   NOTE: If you have previously secured these directories, setting this to
#   'false' will *not* set them to any particular other mode. This is because
#   there is no way to know why you are changing these settings or what,
#   exactly, you want them to be.
#
#   [*tmp_opts*]
#     Type: Array of mount options
#     Default: ['noexec','nodev','nosuid']
#
#     If secure_tmp_mount is true, add these options to the /tmp
#     directory. If set to an empty array, it will simply preserve the
#     options that are currently in place.
#
#     Any 'no*' options will override their more permissive
#     counterparts that are currently set on the system.
#
#   [*var_tmp_opts*]
#     Type: Array of mount options
#     Default: ['noexec','nodev','nosuid']
#
#     Works the same way as *tmp_opts* above.
#
#   [*dev_shm_opts*]
#     Type: Array of mount options
#     Default: ['noexec','nodev','nosuid']
#
#     Works the same way as *tmp_opts* above.
#
# === Authors
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::secure_mountpoints (
  $secure_tmp_mounts = true,
  $tmp_opts = ['noexec','nodev','nosuid'],
  $var_tmp_opts = ['noexec','nodev','nosuid'],
  $dev_shm_opts = ['noexec','nodev','nosuid']
) {
  validate_bool($secure_tmp_mounts)
  validate_array($tmp_opts)
  validate_array($var_tmp_opts)
  validate_array($dev_shm_opts)


  # Set some basic mounts (may be RHEL specific...)
  mount { '/dev/pts':
    ensure   => 'mounted',
    device   => 'devpts',
    fstype   => 'devpts',
    options  => 'rw,gid=5,mode=620,noexec',
    dump     => '0',
    pass     => '0',
    target   => '/etc/fstab',
    remounts => true
  }

  mount { '/sys':
    ensure   => 'mounted',
    device   => 'sysfs',
    fstype   => 'sysfs',
    options  => 'rw,nodev,noexec',
    pass     => '0',
    target   => '/etc/fstab',
    remounts => true
  }

  # If we decide to secure the tmp mounts....
  if $secure_tmp_mounts {
    # If /tmp is mounted
    if getvar('::tmp_mount_tmp') and !empty($::tmp_mount_tmp) {
      $tmp_mount_tmp_opts = split($::tmp_mount_tmp,',')

      # If /tmp is not a bind mount and doesn't contain the required options
      # then mount it properly.
      if !array_include($tmp_mount_tmp_opts,'bind') {
        mount { '/tmp':
          ensure   => 'mounted',
          target   => '/etc/fstab',
          fstype   => $::tmp_mount_fstype_tmp,
          options  => join_mount_opts($tmp_mount_tmp_opts,$tmp_opts),
          device   => $::tmp_mount_path_tmp,
          pass     => '1',
          remounts => true
        }
      }
      else {
        mount { '/tmp':
          ensure   => 'mounted',
          target   => '/etc/fstab',
          fstype   => 'none',
          options  => join_mount_opts(['bind'],$tmp_opts),
          device   => $::tmp_mount_path_tmp,
          remounts => true
        }

        if !empty(difference($tmp_opts,$tmp_mount_tmp_opts)) {
          $_remount_tmp_opts = join($tmp_opts,',')

          exec { 'remount /tmp':
            command => "/bin/mount -o remount,${_remount_tmp_opts} /tmp",
            require => Mount['/tmp']
          }
        }
      }
    }
    # Otherwise, bind mount it to itself with the correct options.
    # We thought about mounting it to tmpfs but that was just too dangerous
    # without knowing the target environment.
    else {
      mount { '/tmp':
        ensure   => 'mounted',
        target   => '/etc/fstab',
        fstype   => 'none',
        options  => join_mount_opts(['bind'],$tmp_opts),
        device   => '/tmp',
        remounts => true,
        notify   => Exec['remount /tmp']
      }

      exec { 'remount /tmp':
        command     => "/bin/mount -o remount,${tmp_opts} /tmp",
        refreshonly => true
      }
    }

    if (defined('$::simplib::manage_tmp_perms') and
        getvar('::simplib::manage_tmp_perms') and
        getvar('::tmp_mount_tmp')) {
      File['/tmp'] -> Mount['/tmp']
    }

    # If /var/tmp is mounted
    if getvar('::tmp_mount_var_tmp') and !empty($::tmp_mount_var_tmp) {
      $tmp_mount_var_tmp_opts = split($::tmp_mount_var_tmp,',')

      # If /var/tmp is not a bind mount then mount it properly.
      if !array_include($tmp_mount_var_tmp_opts,'bind') {
        mount { '/var/tmp':
          ensure   => 'mounted',
          target   => '/etc/fstab',
          fstype   => $::tmp_mount_fstype_var_tmp,
          options  => join_mount_opts($tmp_mount_var_tmp_opts,$var_tmp_opts),
          device   => $::tmp_mount_path_var_tmp,
          pass     => '1',
          remounts => true
        }
      }
      else {
        mount { '/var/tmp':
          ensure   => 'mounted',
          target   => '/etc/fstab',
          fstype   => 'none',
          options  => join_mount_opts(['bind'],$var_tmp_opts),
          device   => $::tmp_mount_path_var_tmp,
          remounts => true
        }

        if !empty(difference($var_tmp_opts,$tmp_mount_var_tmp_opts)) {
          $_remount_var_tmp_opts = join($var_tmp_opts,',')

          exec { 'remount /var/tmp':
            command => "/bin/mount -o remount,${_remount_var_tmp_opts} /var/tmp",
            require => Mount['/var/tmp']
          }
        }
      }
    }
    # Otherwise, bind mount it to /tmp.
    else {
      mount { '/var/tmp':
        ensure   => 'mounted',
        device   => '/tmp',
        fstype   => 'none',
        options  => join_mount_opts(['bind'],$var_tmp_opts),
        target   => '/etc/fstab',
        remounts => true,
        notify   => Exec['remount /var/tmp']
      }

      exec { 'remount /var/tmp':
        command     => "/bin/mount -o remount,${var_tmp_opts} /var/tmp",
        refreshonly => true
      }
    }

    if (defined('$::simplib::manage_tmp_perms') and
        getvar('::simplib::manage_tmp_perms')  and
        getvar('::tmp_mount_var_tmp')) {
      File['/var/tmp'] -> Mount['/var/tmp']
    }

    # If /dev/shm is mounted
    if getvar('::tmp_mount_dev_shm') and !empty($::tmp_mount_dev_shm) {
      $tmp_mount_dev_shm_opts = split($::tmp_mount_dev_shm,',')

      # If /dev/shm doesn't contain the required options then mount it
      # properly.
      mount { '/dev/shm':
        ensure   => 'mounted',
        options  => join_mount_opts($tmp_mount_dev_shm_opts,$dev_shm_opts),
        device   => $::tmp_mount_path_dev_shm,
        fstype   => 'tmpfs',
        target   => '/etc/fstab',
        remounts => true
      }
    }

    if $::operatingsystem in ['RedHat','CentOS'] and (versioncmp($::operatingsystemmajrelease,'6') == 0) {
      include 'upstart'

      # There is a bizarre bug where /tmp and /var/tmp will have incorrect
      # permissions after the *second* reboot after bootstrapping SIMP. This
      # upstart job is an effective, but kludgy, way to remedy this issue. We
      # have not been able to repeat the issue reliably enough in a
      # controlled environment to determine the root cause.
      upstart::job { 'fix_tmp_perms':
        main_process_type => 'script',
        main_process      => '
perm1=$(/usr/bin/find /tmp -maxdepth 0 -perm -ugo+rwxt | /usr/bin/wc -l)
perm2=$(/usr/bin/find /var/tmp -maxdepth 0 -perm -ugo+rwxt | /usr/bin/wc -l)

if [ "$perm1" != "1" ]; then
  /bin/chmod ugo+rwxt /tmp
fi

if [ "$perm2" != "1" ]; then
  /bin/chmod ugo+rwxt /var/tmp
fi
',
        start_on          => 'runlevel [0123456]',
        description       => 'Used to enforce /tmp and /var/tmp permissions to be 777.'
      }
    }
  }
}
