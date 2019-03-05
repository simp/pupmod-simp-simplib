# Matches valid cron weekday parameter
#
type Simplib::Cron::WeekDay = Pattern['^(?:\?|\*|(?:\*)?(?:\/(?:[0-7]))|L|(?:[0-7])(?:(?:#[1-5])|(?:(?:(?:-|\/|,)[0-7])?(?:L)?))?(?:(?:,[0-7])(?:(?:#[1-5])|(?:(?:(?:-|\/|,)[0-7])?(?:L)?)))*|(?:SUN|MON|TUE|WED|THU|FRI|SAT|sun|mon|tue|wed|thu|fri|sat)(?:#[1-5])|(?:SUN|MON|TUE|WED|THU|FRI|SAT|sun|mon|tue|wed|thu|fri|sat)(?:,(?:SUN|MON|TUE|WED|THU|FRI|SAT|sun|mon|tue|wed|thu|fri|sat))*)$']
