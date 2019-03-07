# Matches valid cron month parameter
#
type Simplib::Cron::Month = Variant[Integer[1,12],Pattern['(?x)^(?:\*|
(?:\*\/(?:[1-9]|1[012]))|
(?:(?:[1-9]|1[012])(?:(?:-(?:[1-9]|1[012]))(?:\/(?:[1-9]|1[012]))?)?)|
(?i)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)
)$']]
