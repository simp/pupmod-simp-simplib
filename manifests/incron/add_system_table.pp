# _Description_
#
# Add a system table $name to /etc/incron.d
#
# _Variables_
# * $name
#   The name of the table in /etc/incron.d/
define simplib::incron::add_system_table (
# * $path
#   Filesystem path to monitor
  $path = '',
# * $mask
#   Symbolic array or numeric mask for events
  $mask = ['IN_MODIFY','IN_MOVE','IN_CREATE','IN_DELETE'],
# * $command
#   Command to run on detection of event in $path
  $command = '',
# * $custom_content
#   Custom content to add to /etc/incron.d/$name
  $custom_content = ''
) {
  include 'simplib::incron'

  if empty($path) and empty($command) and empty($custom_content) {
    fail ('You must specify either $path and $command or $custom_content.')
  }

  validate_absolute_path($path)
  if !is_integer($mask) {
    validate_array($mask)
    validate_re_array($mask,[
      'IN_ACCESS',
      'IN_ATTRIB',
      'IN_CLOSE_WRITE',
      'IN_CLOSE_NOWRITE',
      'IN_CREATE',
      'IN_DELETE',
      'IN_DELETE_SELF',
      'IN_MODIFY',
      'IN_MOVE_SELF',
      'IN_MOVED_FROM',
      'IN_MOVED_TO',
      'IN_OPEN',
      'IN_ALL_EVENTS',
      'IN_MOVE',
      'IN_CLOSE',
      'IN_DONT_FOLLOW',
      'IN_ONESHOT',
      'IN_ONLYDIR',
      'IN_NO_LOOP'
    ])
  }

  $_mask    = join($mask,',')
  $_content = $custom_content ? {
      ''      => "${path} ${_mask} ${command}\n",
      default => "${custom_content}\n"
  }

  file { "/etc/incron.d/${name}":
    content => $_content,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['incron'],
    notify  => Service['incrond']
  }
}
