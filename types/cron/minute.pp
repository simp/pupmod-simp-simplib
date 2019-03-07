# Matches valid cron minute parameter
#
type Simplib::Cron::Minute = Variant[Integer[0,59],Pattern['(?x)^(?:\*|
(?:\*\/(?:[0-5]?\d))|
(?:(?:[0-5]?\d)(?:(?:-(?:[0-5]?\d))(?:\/(?:[0-5]?\d))?)?)
)$']]
