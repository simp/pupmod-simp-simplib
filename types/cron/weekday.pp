# Matches valid cron weekday parameter
#
type Simplib::Cron::WeekDay = Pattern['\\?|\\*|L|(?:[0-7])(?:(?:#[0-7])|(?:(?:-|\/|,)[0-7](?:L)?))?(?:,(?:#[0-7])|(?:(?:-|\/|,)[0-7](?:L)?))*|(?:SUN|MON|TUE|WED|THU|FRI|SAT)(?:,(?:SUN|MON|TUE|WED|THU|FRI|SAT))*']
