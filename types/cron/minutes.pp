# Matches valid cron minute parameter
#
type Simplib::Cron::Minute = Pattern['\\*|(?:[0-5]?\\d)(?:(?:-|\/|,)(?:[0-5]?\\d))?(?:,(?:[0-5]?\\d)(?:(?:-|\/|,)(?:[0-5]?\\d))?)*']
