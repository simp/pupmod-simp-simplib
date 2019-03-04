# Matches valid cron month parameter
#
type Simplib::Cron::Month = Pattern['\\*|(?:[1-9]|1[012])(?:(?:-|\/|,)(?:[1-9]|1[012]))?(?:,(?:[1-9]|1[012])(?:(?:-|\/|,)(?:[1-9]|1[012]))?)*|(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(?:,(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))*']
