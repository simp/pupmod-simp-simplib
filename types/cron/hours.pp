# Matches valid cron hour parameter
#
type Simplib::Cron::Hour = Pattern['\\*|(?:[01]?\\d|2[0-3])(?:(?:-|\/|,)(?:[01]?\\d|2[0-3]))?(?:,(?:[01]?\\d|2[0-3])(?:(?:-|\/|,)(?:[01]?\\d|2[0-3]))?)*']
