# _Description_
#
# Set up a YUM update schedule.
#
class simplib::yum_schedule (
# _Variables_
    $minute = '12',
    $hour = '0',
    $monthday = '*',
    $month = '*',
    $weekday = '*',
# $repos
#     If you only want to update from specific repos, then set the repos
#     variable to an array with those repo names.
    $repos = ['all'],
# $disable
#     If you want to disable specific repos, then set the $disable
#     variable to an array with those repo names.
    $disable = [],
# $exclude_pkgs
#     Packages to exclude from the update.
    $exclude_pkgs = [],
# $randomize
#     Set to the number of minutes you want yum to randomly wait within before
#     running.  The default is '5'.
    $randomize = '5',
# $quiet
#     Set to false if you want to see the chatter from yum.
    $quiet = true
) {
  validate_array($repos)
  validate_array($disable)
  validate_array($exclude_pkgs)
  validate_integer($randomize)
  validate_bool($quiet)

  compliance_map()

  cron { 'yum_update':
    command  => template('simplib/yum-cron.erb'),
    user     => 'root',
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
    month    => $month,
    weekday  => $weekday
  }
}
