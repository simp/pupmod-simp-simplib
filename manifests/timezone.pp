# == Class timezone
#
# Copies the appropriate file from /etc/localtime to /etc/localtime.
#
# == Parameters
#
# [*zone*]
#   The timezone to set to localtime.  Must be the name of a file in
#   /usr/share/zoneinfo/
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::timezone (
  $zone = 'GMT'
) {
  validate_string($zone)

  file { '/etc/localtime':
    source => "/usr/share/zoneinfo/${zone}",
    force  => true,
    backup => false
  }
}
