# _Description_
#
# Allow for the configuration of /etc/sysconfig/init
#
# See /usr/share/doc/initscripts-<version>/sysconfig.txt for variable
#   definitions.
#
# _Templates_
#
# * sysconfig/init.erb
#
class simplib::sysconfig::init (
  $bootup = 'color',
  $res_col = '60',
  # The weird formatting here is just to get puppet lint to be quiet
  # until this can get fixed.
  $move_to_col = "\"echo -en \\\\033[\${RES_COL}G\"",
  $setcolor_success = '"echo -en \\033[0;32m"',
  $setcolor_failure = '"echo -en \\033[0;31m"',
  $setcolor_warning = '"echo -en \\033[0;33m"',
  $setcolor_normal = '"echo -en \\033[0;39m"',
  $single_user_login = '/sbin/sulogin',
  $loglvl = '3',
  $prompt = false,
  $autoswap = false
) {
  validate_string($single_user_login)
  validate_integer($res_col)
  validate_re($loglvl,'^[1-8]$')
  validate_bool($prompt)
  validate_bool($autoswap)

  file { '/etc/sysconfig/init':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('simplib/etc/sysconfig/init.erb')
  }
}
