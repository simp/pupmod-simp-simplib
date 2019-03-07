# Matches valid cron monthday parameter
#
# Tested with Rubular: https://rubular.com/r/ovqrYiCurMdQir
type Simplib::Cron::MonthDay = Variant[Integer[1,31],Pattern['^(?x)(?:\*|
(?:\*\/(?:[1-9]|[12]\d|3[01]))|
(?:(?:[1-9]|[12]\d|3[01])(?:(?:-(?:[1-9]|[12]\d|3[01]))(?:\/(?:[1-9]|[12]\d|3[01]))?)?)
)$']]
