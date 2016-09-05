# _Description_
#
# Set the swappiness of the system either by a cron job or as an absolute value.
#
# The cron job is run every 5 minutes by default. Using the cron job doesn't
# really make a lot of sense unless it is run reasonably often. Therefore, only
# minute steps are supported per crontab(5).
#
# An absolute value setting will always override the cron job.
class simplib::swappiness(
# _Variables_
#
# $cron_step:
#     The crontab(5) minute step value for the swappiness set.
    $cron_step = '5',
# $maximum:
#     The percentage of memory free on the system above which we will set
#     vm.swappiness to $min_swappiness
    $maximum = '30',
# $median:
#     If the percentage of free memory on the system is between this number and
#     $maximum, set vm.swappiness to $low_swappiness.
    $median = '10',
# $minimum:
#     If the percentage of free memory on the system is between this number and
#     $median, set vm.swappiness to $high_swappiness.  If below this number,
#     set to $max_swappiness.
    $minimum = '5',
# $min_swappiness:
#     The minimum swappiness to ever set on the system.
    $min_swappiness = '5',
# $low_swappiness:
#     The next level of swappiness to jump to on the system.
    $low_swappiness = '20',
# $high_swappiness:
#     The medium-high level of swappiness to set on the sysetm.
    $high_swappiness = '40',
# $max_swappiness:
#     The absolute maximum to ever set the swappiness on the system.
    $max_swappiness = '80',
# $absolute_swappiness:
#     Set the system to run at this swappiness and do not adjust. Take care,
#     whatever value you place in here is converted to an integer and used
#     as-is!
    $absolute_swappiness = false
  ) {
  validate_integer($cron_step)
  validate_integer($maximum)
  validate_integer($median)
  validate_integer($minimum)
  validate_integer($min_swappiness)
  validate_integer($low_swappiness)
  validate_integer($high_swappiness)
  validate_integer($max_swappiness)

  if !is_integer($absolute_swappiness) { validate_bool($absolute_swappiness) }

  if ! $absolute_swappiness {
    file { '/usr/local/sbin/dynamic_swappiness.rb':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('simplib/dynamic_swappiness.erb')
    }

    cron { 'dynamic_swappiness':
      user    => 'root',
      minute  => "*/${cron_step}",
      command => '/usr/local/sbin/dynamic_swappiness.rb',
      require => File['/usr/local/sbin/dynamic_swappiness.rb']
    }
  }
  else {
    include 'sysctl'

    sysctl { 'vm.swappiness':
      ensure => present,
      value  => inline_template('<%= @absolute_swappiness.to_i %>')
    }

    cron { 'dynamic_swappiness':
      ensure => absent
    }
  }
}
