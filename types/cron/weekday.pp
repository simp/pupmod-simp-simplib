# Matches valid cron weekday parameter
#
type Simplib::Cron::WeekDay = Pattern['^(?:\*|(?:\*)?(?:\/(?:[0-7]))|(?:[0-7])(?:(?:-|\/|,)[0-7])?(?:(?:,[0-7])(?:(?:-|\/|,)[0-7]))*|(?:SUN|MON|TUE|WED|THU|FRI|SAT|sun|mon|tue|wed|thu|fri|sat)(?:,(?:SUN|MON|TUE|WED|THU|FRI|SAT|sun|mon|tue|wed|thu|fri|sat))*)$']
