# Matches valid cron weekday parameter
#
type Simplib::Cron::WeekDay = Pattern['(?x)^(?:\*|
(?:\*\/(?:[0-7]))|
(?:(?:[0-7])(?:(?:-[0-7]\/[0-7])|(?:(?:-|,)[0-7]))?(?:(?:,[0-7])(?:(?:-[0-7]\/[0-7])|(?:(?:-|,)[0-7]))?)*)|
(?i)(?:(?:SUN|MON|TUE|WED|THU|FRI|SAT)(?:,(?:SUN|MON|TUE|WED|THU|FRI|SAT))*)(?-i))$']
