# == Class: simplib::prelink
#
# This class manages the prelink settings on a system.
#
# == Parameters
#
# [*enable*]
# Type: Boolean
# Default: false
#   If true, enable prelinking.
#
#   Set to false by default to meet CCE-27221-1
#
# [*opts*]
# Type: String
# Default: '-mR'
#   The default options to pass to prelink.
#
# [*full_time_interval*]
# Type: Integer
# Default: 14
#   How often a full prelink should be run.
#
# [*nonrpm_check_interval*]
# Type: Integer
# Default: 7
#   How often prelink should be run even if no RPM packages have been updated.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::prelink (
  $enable = false,
  $opts = '-mR',
  $full_time_interval = '14',
  $nonrpm_check_interval = '7'
){
  validate_bool($enable)
  validate_integer($full_time_interval)
  validate_integer($nonrpm_check_interval)

  if $enable {
    package { 'prelink':
      ensure => 'latest',
      before => File['/etc/sysconfig/prelink']
    }
  }

  file { '/etc/sysconfig/prelink':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('simplib/etc/sysconfig/prelink.erb')
  }
}
