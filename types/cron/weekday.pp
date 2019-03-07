# Matches valid cron weekday parameter
#
type Simplib::Cron::WeekDay = Variant[Integer[1,7],Pattern['(?x)^(?:\*|
(?:\*\/(?:[0-7]))|
(?:(?:[0-7])(?:(?:-[0-7])(?:\/[0-7])?)?)|
(?i)(?:SUN|MON|TUE|WED|THU|FRI|SAT)
)$']]
