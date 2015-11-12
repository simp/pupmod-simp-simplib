# _Description_
#
# Sets up /etc/libuser.conf.
# See libuser.conf(5) for information on the various variables.
#
class simplib::libuser_conf (
  $defaults_create_modules=['files','shadow'],
  $defaults_crypt_style='sha512',
  $defaults_hash_rounds_min='',
  $defaults_hash_rounds_max='',
  $defaults_mailspooldir='',
  $defaults_moduledir='',
  $defaults_modules=['files','shadow'],
  $defaults_skeleton='',
  $import_login_defs='/etc/login.defs',
  $import_default_useradd='/etc/default/useradd',
  $userdefaults='LU_USERNAME = %n
LU_GIDNUMBER = %u',
  $groupdefaults='LU_GROUPNAME = %n',
  $files_directory='',
  $files_nonroot='',
  $shadow_directory='',
  $shadow_nonroot='',
  $ldap_userBranch='',
  $ldap_groupBranch='',
  $ldap_server='',
  $ldap_basedn='',
  $ldap_binddn='',
  $ldap_user='',
  $ldap_password='',
  $ldap_authuser='',
  $ldap_bindtype='',
  $sasl_appname='',
  $sasl_domain=''
) {
  validate_array($defaults_create_modules)
  validate_array_member($defaults_create_modules,['files','shadow','ldap'])
  validate_array_member($defaults_crypt_style,['des','blowfish','sha256','sha512'])
  validate_array($defaults_modules)
  validate_array_member($defaults_modules,['files','shadow','ldap'])

  file { '/etc/libuser.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('simplib/etc/libuser.conf.erb')
  }
}
