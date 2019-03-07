# Matches valid cron hour parameter
#
type Simplib::Cron::Hour = Variant[Integer[0,23],Pattern['(?x)^(?:\*|
(?:\*\/(?:[01]?\d|2[0-3]))|
(?:(?:[01]?\d|2[0-3])(?:(?:-(?:[01]?\d|2[0-3]))(?:\/(?:[01]?\d|2[0-3]))?)?)
)$']]
