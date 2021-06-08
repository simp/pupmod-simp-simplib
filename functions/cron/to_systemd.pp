# Convert a set of 'cron' native type parameters to a 'best effort' systemd
# calendar String
#
# @param minute
#   The `minute` parameter from the cron resource
#
# @param hour
#   The `hour` parameter from the cron resource
#
# @param month
#   The `month` parameter from the cron resource
#
# @param monthday
#   The `monthday` parameter from the cron resource
#
# @param weekday
#   The `weekday` parameter from the cron resource
#
# @return [String]
#
function simplib::cron::to_systemd(
  Simplib::Cron::Minute            $minute   = '*',
  Simplib::Cron::Hour              $hour     = '*',
  Simplib::Cron::Month             $month    = '*',
  Simplib::Cron::Monthday          $monthday = '*',
  Optional[Simplib::Cron::Weekday] $weekday  = undef
) {
  $_month = $month ? {
    /(?i:jan)/ => 1,
    /(?i:feb)/ => 2,
    /(?i:mar)/ => 3,
    /(?i:apr)/ => 4,
    /(?i:may)/ => 5,
    /(?i:jun)/ => 6,
    /(?i:jul)/ => 7,
    /(?i:aug)/ => 8,
    /(?i:sep)/ => 9,
    /(?i:oct)/ => 10,
    /(?i:nov)/ => 11,
    /(?i:dec)/ => 12,
    default    => $month
  }

  $_weekday = $weekday ? {
    '*'     => undef,
    0       => 'Sun',
    1       => 'Mon',
    2       => 'Tue',
    3       => 'Wed',
    4       => 'Thu',
    5       => 'Fri',
    6       => 'Sat',
    default => $weekday
  }

  strip(
    join(
      [
        $_weekday,
        join([$_month, $monthday], '-'),
        join([$hour, $minute], ':')
      ],
      ' '
    )
  )
}
