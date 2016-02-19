# == Class: sec::chkrootkit
#
# Sets up chkrootkit to be run once per week with results sent to syslog by
# default.
#
# == Parameters
#
# [*destination*]
# Type: String
# Default: 'syslog'
#   Set to 'syslog' (default) to output to local6.notice or anything else to
#   just use the normal cron output destination.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::chkrootkit (
  $minute = '0',
  $hour = '0',
  $monthday = '*',
  $month = '*',
  $weekday = '0',
  $destination = 'syslog'
) {
  compliance_map()

  $_command = $destination ? {
    'syslog' => '/usr/sbin/chkrootkit -n | /bin/logger -p local6.notice -t chkrootkit',
    default  => '/usr/sbin/chkrootkit -n'
  }

  cron { 'chkrootkit':
    command  => $_command,
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
    weekday  => $weekday,
    require  => Package['chkrootkit']
  }

  package { 'chkrootkit': ensure => 'latest' }
}
