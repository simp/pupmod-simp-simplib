# == Class: simplib::profile_settings
#
# This class takes various simplib security-related settings and
# applies them to the appropriate /etc/profile.d/simp.* files to
# enforce them at login for all users.
#
# Currently only supports csh and sh files in profile.d.
#
# == Parameters
#
# [*session_timeout*]
# Type: Integer
# Default: 15
#   The number of *minutes* that a user may be idle prior to being
#   logged out. This is a logical extension of the SCAP Security Guide
#   requirements for Graphical and SSH timeouts and takes the place of
#   a terminal screen lock since we haven't found one that works in
#   100% of the authentication scenarios.
#
# [*umask*]
# Type: Umask
# Default: 0077
#   The umask that will be applied to the user upon login.
#   Covers CCE-26917-5, CCE-27034-8, and CCE-26669-2
#
# [*mesg*]
# Type: Boolean
# Default: false
#   If true, set mesg to allow writes to user terminals using wall,
#   etc...
#
# [*user_whitelist*]
# Type: Array of Usernames
# Default: []
#   A list of users that you don't want to be affected by these
#   settings.
#
# [*prepend*]
# Type: Hash
# Default: {}
#   Content that you want prepended to the settings scripts.
#   The hash takes the form 'extension' => 'content'.
#   Content will be written exactly as provided, no custom formatting
#   will be performed.
#
#   Example:
#     { 'sh' => 'if [ $UID -eq 0 ]; then echo "foo"; fi ' }
#   Result:
#     = /etc/profile.d/simp.sh =
#      if [ $UID -eq 0 ]; then echo "foo"; fi
#      <usual content>
#
# [*append*]
# Type: Hash
# Default: {}
#   Content that you want appended to the settings scripts.
#   See $prepend for usage.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
class simplib::profile_settings (
  $session_timeout = '15',
  $umask = '0077',
  $mesg = false,
  $user_whitelist = [],
  $prepend = {},
  $append = {}
){
  validate_integer($session_timeout)
  validate_umask($umask)
  validate_bool($mesg)
  validate_array($user_whitelist)
  validate_hash($prepend)
  validate_hash($append)

  compliance_map()

  file { '/etc/profile.d/simp.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    seltype => 'bin_t',
    content => template('simplib/etc/profile.d/simp.sh.erb')
  }

  file { '/etc/profile.d/simp.csh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    seltype => 'bin_t',
    content => template('simplib/etc/profile.d/simp.csh.erb')
  }
}
