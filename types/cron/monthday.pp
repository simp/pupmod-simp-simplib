# Matches valid cron monthday parameter
#
type Simplib::Cron::MonthDay = Variant[Integer[1,31],Pattern['(?x)^(?:\*|
(?:\*\/(?:[1-9]|[12]\d|3[01]))|
(?:(?:[1-9]|[12]\d|3[01])(?:(?:-(?:[1-9]|[12]\d|3[01]))(?:\/(?:[1-9]|[12]\d|3[01]))?)?)
)$']]
