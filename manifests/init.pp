# == Class: simplib
#
# The entry point for a host of items that do not warrant their own
# module space.
#
# This class, in particular, houses a lot of options that you will
# want on pretty much all systems but aren't complex enough to warrant
# their own class.
#
# == Parameters
# [*user_umask*]
# Type: Umask
# Default: 0077
#   The default umask for all users on the system. This is set in
#   /etc/csh.cshrc and /etc/bashrc.
#
#   As set, meets CCE-26917-5 and CCE-27034-8
#
# [*daemon_umask*]
# Type: Umask
# Default: 0027
#   The default umask for all system daemons. This is set in
#   /etc/rc.d/init.d/functions.
#
#   As set, meets CCE-27031-4
#
# [*core_dumps*]
# Type: Boolean
# Default: false
#   If true, enable core dumps on the system.
#
#   As set, meets CCE-27033-0
#
# [*max_logins*]
# Type: Integer
# Default: 10
#   The number of logins that an account may have on the system at a given time
#   as enforced by PAM.
#
#   As set, meets CCE-27457-1
#
# [*ftpusers_min*]
# Type: Integer
# Default: 500
#   The start of the local user account IDs. This is used to populate
#   /etc/ftpusers with all system accounts (below this number) so that
#   they cannot ftp into the system.
#
#   Set to an empty string ('') to disable.
#
# [*disable_rc_local*]
# Type: Boolean
# Default: true
#   If true, disable the use of the /etc/rc.local file.
#
# [*disable_hosts_equiv*]
# Type: Boolean
# Default: true
#   If true, ensure that the /etc/hosts.equiv file does not exist.
#
#   As set, meets CCE-27270-8
#
# [*shells*]
# Type: Array of absolute paths
# Default: [
#    '/bin/sh',
#    '/bin/zsh',
#    '/bin/bash',
#    '/sbin/nologin'
#  ]
#   The set of shells that are valid for the system. It is recommended
#   that you leave at least /bin/sh and /sbin/nologin in this list if
#   you decide to change it.
#
# [*securetty*]
# Type: Array of TTYs
# Default: [
#   'console',
#   'tty1',
#   'tty2',
#   'tty3',
#   'tty4',
#   'tty5',
#   'tty6',
#   'ttyS0',
#   'ttyS1'
# ]
#   The set of TTYs that root is allowed to login on.
#   According to CCE-26891-2, this should be an empty list but we feel
#   that this is too dangerous for a default.
#
# [*manage_tmp_perms*]
# Type: Boolean
# Default: true
#   Ensure that  /tmp, /var/tmp, and /usr/tmp, all have the proper
#   permissions and SELinux contexts.
#
# [*manage_root_perms*]
# Type: Boolean
# Default: true
#   Ensure that /root has restricted permissions and proper SELinux
#   contexts.
#
# [*use_fips*]
# Type: Boolean
# Default: false
#   If enabled, the system will be FIPS 140-2 enabled.
#
# [*use_fips_aesni*]
# Type: Boolean
# Default: true
#   If enabled and $use_fips is true, then install dracut-fips-aesni
#
# [*runlevel*]
# Type: 1-5, rescue, multi-user, or graphical
# Default: 3
#   The default runlevel to which the system should be set.
#
# [*proc_hidepid*]
# Type: 0|1|2*
# Default: 2
#   0: This is the default setting and gives you the default
#   behaviour.
#
#   1: With this option an normal user would not see other processes
#   but their own about ps, top etc, but he is still able to see
#   process IDs in /proc
#
#   2 (default): Users are only able too see their own processes (like
#   with hidepid=1), but also the other process IDs are hidden for
#   them in /proc!
#
#   If you undefine this option, then this class will not manage
#   /proc.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib (
  $user_umask = '0077',
  $daemon_umask = '0027',
  $core_dumps = false,
  $max_logins = '10',
  $ftpusers_min = '500',
  $disable_rc_local = true,
  $disable_hosts_equiv = true,
  $shells = [
    '/bin/sh',
    '/bin/zsh',
    '/bin/bash',
    '/sbin/nologin'
  ],
  $securetty = [
    'console',
    'tty1',
    'tty2',
    'tty3',
    'tty4',
    'tty5',
    'tty6',
    'ttyS0',
    'ttyS1'
  ],
  $manage_tmp_perms = true,
  $manage_root_perms = true,
  $use_fips = hiera('use_fips', false),
  # I'm not entirely sure what happens if you mix CPUs and one doesn't have AES
  # enabled...
  $use_fips_aesni = $::cpuinfo and member($::cpuinfo['processor0']['flags'],'aes'),
  $runlevel = '3',
  $proc_hidepid = '2'
){
  validate_umask($user_umask)
  validate_umask($daemon_umask)
  validate_bool($core_dumps)
  validate_integer($max_logins)
  if !empty($ftpusers_min) { validate_integer($ftpusers_min) }
  validate_bool($disable_rc_local)
  validate_bool($disable_hosts_equiv)
  validate_array($shells)
  validate_re_array($shells,'^/')
  validate_array($securetty)
  validate_bool($manage_tmp_perms)
  validate_bool($manage_root_perms)
  validate_bool($use_fips)
  validate_bool($use_fips_aesni)
  validate_array_member($proc_hidepid,['0','1','2'])

  runlevel { $runlevel: }

  if $use_fips {
    kernel_parameter { 'fips':
      value  => '1',
      notify => Reboot_notify['fips']
      # bootmode => 'normal', # This doesn't work due to a bug in the Grub Augeas Provider
    }

    kernel_parameter { 'boot':
      value  => "UUID=${::boot_dir_uuid}",
      notify => Reboot_notify['fips']
      # bootmode => 'normal', # This doesn't work due to a bug in the Grub Augeas Provider
    }

    package { 'dracut-fips':
      ensure => 'latest',
      notify => Exec['dracut_rebuild']
    }
    package { 'fipscheck':
      ensure => 'latest'
    }

    if $use_fips_aesni {
      package { 'dracut-fips-aesni':
        ensure => 'latest',
        notify => Exec['dracut_rebuild']
      }
    }
  }
  else {
    kernel_parameter { 'fips':
      value  => '0',
      notify => Reboot_notify['fips']
      # bootmode => 'normal', # This doesn't work due to a bug in the Grub Augeas Provider
    }
  }

  reboot_notify { 'fips': }

  # If the NSS and dracut packages don't stay reasonably in sync, your system
  # may not reboot.
  package { 'nss': ensure => 'latest' }

  exec { 'dracut_rebuild':
    command     => '/sbin/dracut -f',
    subscribe   => Package['nss'],
    refreshonly => true
  }

  if !empty($ftpusers_min) {
    file { '/etc/ftpusers':
      ensure => 'file',
      force  => true,
      owner  => 'root',
      group  => 'root',
      mode   => '0600'
    }

    ftpusers { '/etc/ftpusers': min_id => $ftpusers_min }
  }

  if $disable_hosts_equiv {
    file { '/etc/hosts.equiv': ensure => 'absent' }
  }

  if $disable_rc_local {
    file { '/etc/rc.d/rc.local':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => "Managed by Puppet, manual changes will be erased\n"
    }

    file { '/etc/rc.local':
      ensure => 'symlink',
      target => '/etc/rc.d/rc.local'
    }
  }

  # Setting a few mandatory permissions
  # CCE-26953-0
  # CCE-26856-5
  # CCE-26868-0
  file { [ '/etc/passwd', '/etc/passwd-' ]:
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  # CCE-26947-2
  # CCE-26967-0
  # CCE-26992-8
  # CCE-27026-4
  # CCE-26975-3
  # CCE-26951-4
  file { [
    '/etc/shadow',
    '/etc/shadow-',
    '/etc/gshadow',
    '/etc/gshadow-'
  ]:
    owner => 'root',
    group => 'root',
    mode  => '0000'
  }

  # CCE-26822-7
  # CCE-26930-8
  # CCE-26954-8
  file { [
    '/etc/group',
    '/etc/group-'
  ]:
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  file { '/etc/securetty':
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => join($securetty,"\n")
  }

  file { '/etc/shells':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => join($shells,"\n")
  }

  file { '/etc/security/opasswd':
    owner => 'root',
    group => 'root',
    mode  => '0600'
  }

  if $manage_tmp_perms {
    file { '/tmp':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => 'u+rwx,g+rwx,o+rwxt',
      force  => true
    }

    file { '/var/tmp':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => 'u+rwx,g+rwx,o+rwxt',
      force  => true
    }

    file { '/usr/tmp':
      ensure  => 'symlink',
      target  => '/var/tmp',
      force   => true,
      seltype => 'tmp_t',
      require => File['/var/tmp']
    }
  }

  if $manage_root_perms {
    file { '/root':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0700'
    }
  }

  file { '/usr/local/sbin/simp':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  if ($proc_hidepid) {
    mount { '/proc':
      ensure   => 'mounted',
      atboot   => true,
      device   => 'proc',
      fstype   => 'proc',
      remounts => true,
      options  => "hidepid=${proc_hidepid}"
    }
  }

  if !$core_dumps {
    pam::limits::add { 'prevent_core':
      domain => '*',
      type   => 'hard',
      item   => 'core',
      value  => '0',
      order  => '100'
    }
  }

  pam::limits::add { 'max_logins':
    domain => '*',
    type   => 'hard',
    item   => 'maxlogins',
    value  => $max_logins,
    order  => '100'
  }

  script_umask { '/etc/csh.cshrc': umask => $user_umask }
  script_umask { '/etc/bashrc': umask => $user_umask }
  script_umask { '/etc/rc.d/init.d/functions': umask => $daemon_umask }

  user { 'root':
    ensure     => 'present',
    uid        => '0',
    gid        => '0',
    allowdupe  => false,
    home       => '/root',
    shell      => '/bin/bash',
    groups     => [ 'bin', 'daemon', 'sys', 'adm', 'disk', 'wheel' ],
    membership => 'minimum',
    forcelocal => true
  }

  group { 'root':
    ensure          => 'present',
    gid             => '0',
    allowdupe       => false,
    auth_membership => true,
    forcelocal      => true,
    members         => ['root']
  }

  file { "${::puppet_vardir}/simp":
    ensure => 'directory',
    mode   => '0750',
    owner  => 'root',
    group  => 'puppet'
  }
}
