# _Description_
#
# Install and configure the useradd default configuration file.
# See useradd(8) for more details.
#
# _Templates_
#
# * etc_default/useradd.erb
class simplib::etc_default::useradd (
  $group = '100',
  $home = '/home',
  $inactive = '35',
  $expire = '',
  $shell = '/bin/bash',
  $skel = '/etc/skel',
  $create_mail_spool = true
) {

  file { '/etc/default/useradd':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('simplib/etc/default/useradd.erb')
  }

  validate_integer($group)
  validate_absolute_path($home)
  validate_integer($inactive)
  if !empty($expire) { validate_re($expire,'^\d{4}-\d{2}-\d{2}$') }
  validate_absolute_path($shell)
  validate_absolute_path($skel)
  validate_bool($create_mail_spool)
}

