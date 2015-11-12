# == Class: simplib::login_defs
#
# Set up the /etc/login.defs configuration file.
# All option values are taken directly from the system documentation.
#
# Any parameter that is a list will require an array to be passed.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::login_defs (
  $chfn_auth = false,
  $chfn_restrict = 'frwh',
  $chsh_auth = false,
  $console = [],
  $console_groups = [],
  $create_home = true,
  $default_home = false,
  # CCE-27228-6
  $encrypt_method = 'SHA512',
  $env_hz = '',
  $env_path = [],
  $env_supath = [],
  $env_tz = '',
  $environ_file = '',
  $erasechar = '',
  $fail_delay = '4',
  $faillog_enab = true,
  $fake_shell = '',
  $ftmp_file = '',
  $gid_max = '500000',
  $gid_min = '500',
  $hushlogin_file = '',
  $issue_file = '/etc/issue',
  $killchar = '',
  $lastlog_enab = true,
  $log_ok_logins = true,
  $log_unkfail_enab = true,
  $login_retries = '3',
  $login_string = '',
  $login_timeout = '60',
  $mail_check_enab = true,
  $mail_dir = '/var/spool/mail',
  $mail_file = '',
  $max_members_per_group = '',
  $motd_file = [],
  $nologins_file = '',
  $obscure_checks_enab = true,
  $pass_always_warn = true,
  $pass_change_tries = '3',
  # CCE-26985-2
  $pass_max_days = '180',
  # CCE-27013-2
  $pass_min_days = '1',
  # CCE-26998-6
  $pass_warn_age = '14',
  $pass_max_len = '',
  # CCE-27002-5
  $pass_min_len = '14',
  $porttime_checks_enab = true,
  $quotas_enab = true,
  $sha_crypt_min_rounds = '5000',
  $sha_crypt_max_rounds = '10000',
  $sulog_file = '',
  $su_name = 'su',
  $su_wheel_only = false,
  $sys_gid_max = '',
  $sys_gid_min = '',
  $sys_uid_max = '',
  $sys_uid_min = '',
  $syslog_sg_enab = true,
  $syslog_su_enab = true,
  $ttygroup = '',
  $ttyperm = '',
  $ttytype_file = '',
  $uid_max = '1000000',
  $uid_min = '',
  # CCE-26371-5
  $umask = '007',
  # The maximum file size in 512 byte units. Noted here since the man
  # page isn't helpful.
  $ulimit = '',
  $userdel_cmd = '',
  $usergroups_enab = true
) {

  file { '/etc/login.defs':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('simplib/etc/login_defs.erb')
  }

  validate_bool($chfn_auth)
  validate_re($chfn_restrict,'^[frwh]+$')
  validate_bool($chsh_auth)
  validate_array($console)
  validate_array($console_groups)
  validate_bool($create_home)
  validate_bool($default_home)
  validate_array_member($encrypt_method,['DES','MD5','SHA256','SHA512'])
  validate_array($env_path)
  validate_array($env_supath)
  if !empty($environ_file) { validate_absolute_path($environ_file) }
  if !empty($erasechar) { validate_integer($erasechar) }
  validate_integer($fail_delay)
  validate_bool($faillog_enab)
  if !empty($fake_shell) { validate_absolute_path($fake_shell) }
  if !empty($ftmp_file) { validate_absolute_path($ftmp_file) }
  validate_integer($gid_max)
  validate_integer($gid_min)
  if !empty($issue_file) { validate_absolute_path($issue_file) }
  if !empty($killchar) { validate_integer($killchar) }
  validate_bool($lastlog_enab)
  validate_bool($log_ok_logins)
  validate_bool($log_unkfail_enab)
  validate_integer($login_retries)
  validate_integer($login_timeout)
  validate_bool($mail_check_enab)
  validate_absolute_path($mail_dir)
  if !empty($mail_file) { validate_absolute_path($mail_file) }
  if !empty($max_members_per_group) { validate_integer($max_members_per_group) }
  validate_array($motd_file)
  if !empty($nologins_file) { validate_absolute_path($nologins_file) }
  validate_bool($obscure_checks_enab)
  validate_bool($pass_always_warn)
  validate_integer($pass_change_tries)
  validate_integer($pass_max_days)
  validate_integer($pass_min_days)
  validate_integer($pass_warn_age)
  if !empty($pass_max_len) { validate_integer($pass_max_len) }
  validate_integer($pass_min_len)
  validate_bool($porttime_checks_enab)
  validate_bool($quotas_enab)
  validate_integer($sha_crypt_min_rounds)
  validate_integer($sha_crypt_max_rounds)
  if !empty($sulog_file) { validate_absolute_path($sulog_file) }
  validate_bool($su_wheel_only)
  if !empty($sys_gid_max) { validate_integer($sys_gid_max) }
  if !empty($sys_gid_min) { validate_integer($sys_gid_min) }
  if !empty($sys_uid_max) { validate_integer($sys_uid_max) }
  if !empty($sys_uid_min) { validate_integer($sys_uid_min) }
  validate_bool($syslog_sg_enab)
  validate_bool($syslog_su_enab)
  if !empty($ttyperm) { validate_umask($ttyperm) }
  if !empty($ttytype_file) { validate_absolute_path($ttytype_file) }
  validate_integer($uid_max)
  if !empty($uid_min) { validate_integer($uid_min) }
  validate_umask($umask)
  if !empty($ulimit) { validate_integer($ulimit) }
  if !empty($userdel_cmd) { validate_absolute_path($userdel_cmd) }
  validate_bool($usergroups_enab)
}
