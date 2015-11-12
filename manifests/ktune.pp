#
# Class: simplib::ktune
#
# Manages the activation of tuned
# ---
#
class simplib::ktune (
# _Variables_
# $use_sysctl
#     This is the custom sysctl configuration file.  Set to false to
#     use only the ktune settings.
    $use_sysctl = true,
# $use_sysctl_post
#     This is the ktune sysctl file.  Any settings in this file will be applied
#     after custom settings, overriding them.  Comment this out to not use ktune
#     settings.
    $use_sysctl_post = false,
# $io_scheduler
#     This is the I/O scheduler ktune will use.  This will *not* override
#     anything explicitly set on the kernel command line, nor will it change
#     the scheduler for any block device that is using a non-default scheduler
#     when ktune starts.  You should probably leave this on "deadline", but
#     "as", "cfq", and "noop" are also legal values.
    $io_scheduler = 'deadline',
# $elevator_tune_devs
#     These are the devices, that should be tuned with the ELEVATOR
  $elevator_tune_devs = ['hd','sd','cciss'],
# The following options only affect 'tuned'
# $tuning_interval
#     The number of seconds between tuning runs.
    $tuning_interval = '10',
# $diskmonitor_enable
#     Enable the disk monitoring plugin.
    $diskmonitor_enable = true,
# $disktuning_enable
#     Enable the disk tuning plugin.
    $disktuning_enable = true,
# $disktuning_hdparm
#     Use 'hdparm' for disk tuning.
    $disktuning_hdparm = true,
# $disktuning_alpm
#     Use 'ALPM' when disk tuning.
    $disktuning_alpm = true,
# $netmonitor_enable
#     Enable the network monitoring plugin.
    $netmonitor_enable = true,
# $nettuning_enable
#     Enable the network tuning plugin.
    $nettuning_enable = true,
# $cpumonitor_enable
#     Enable the CPU monitoring plugin.
    $cpumonitor_enable = true,
# $cputuning_enable
#     Enable the CPU tuning plugin.
    $cputuning_enable = true
) {
  validate_bool($use_sysctl)
  validate_bool($use_sysctl_post)
  validate_array_member($io_scheduler, ['deadline','as','cfq','noop'])
  validate_integer($tuning_interval)
  validate_bool($diskmonitor_enable)
  validate_bool($disktuning_enable)
  validate_bool($disktuning_hdparm)
  validate_bool($disktuning_alpm)
  validate_bool($netmonitor_enable)
  validate_bool($nettuning_enable)
  validate_bool($cpumonitor_enable)
  validate_bool($cputuning_enable)

  $ktune_name = 'tuned'

  file { '/etc/tuned.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('simplib/etc/tuned.conf.erb'),
    notify  => Service[$ktune_name]
  }

  file { '/etc/sysconfig/ktune':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('simplib/etc/sysconfig/ktune.erb')
  }

  file { '/etc/sysctl.ktune':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  package { $ktune_name:
    ensure => 'latest'
  }

  service { $ktune_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      Package[$ktune_name],
      File['/etc/sysconfig/ktune']
    ]
  }
}
