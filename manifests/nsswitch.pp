# == Class: simplib::nsswitch
#
#   This class configures nsswitch.conf.
#
# == Parameters:
#
# *Any parameter left empty will simply not be included in the file.*
#
# NOTE: Any parameter not defined below simply defaults to ['files'].
#
# [*passwd*]
# Type: Array
# Default: ['files']
#
# If $use_ldap and/or $use_sssd are true, then they will be injected at the end of this array.
#
# If you don't want this, you will need to turn off $use_ldap and/or $use_sssd
# and update the content appropriately.
#
# [*shadow*]
# Type: Array
# Default: ['files']
#
# If $use_ldap and/or $use_sssd are true, then they will be injected at the end of this array.
#
# If you don't want this, you will need to turn off $use_ldap and/or $use_sssd
# and update the content appropriately.
#
# [*group*]
# Type: Array
# Default: ['files']
#
# If $use_ldap is true, then it will be injected at the end of this array.
#
# If you don't want this, you will need to turn off $use_ldap and update the
# content appropriately.
#
# [*initgroups*]
# Type: Array
# Default: []
#
# [*hosts*]
# Type: Array
# Default: ['files','dns']
#
# [*bootparams*]
# Type: Array
# Default: ['nisplus [NOTFOUND=return]','files']
#
# [*netgroup*]
# Type: Array
# Default: ['files']
#
# If $use_sssd is true, then it will be injected at the end of this array.
#
# If you don't want this, you will need to turn off $use_sssd and update the
# content appropriately.
#
# [*publickey*]
# Type: Array
# Default: ['nisplus']
#
# [*automount*]
# Type: Array
# Default: ['files','nisplus']
#
# If $use_ldap is true, then it will be injected at the end of this array.
#
# If you don't want this, you will need to turn off $use_ldap and update the
# content appropriately.
#
# [*aliases*]
# Type: Array
# Default: ['files','nisplus']
#
# [*use_ldap*]
# Type: boolean
# Default: false
#   If true, inject LDAP settings into various options as appropriate.
#
# [*use_sssd*]
# Type: boolean
# Default: false
#   If true, inject SSSD settings into various options as appropriate.
#
# == Authors:
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::nsswitch (
  $passwd =  ['files'],
  $shadow =  ['files'],
  $group =  ['files'],
  $initgroups =  [],
  $hosts =  ['files','dns'],
  $bootparams =  ['nisplus [NOTFOUND=return]','files'],
  $ethers =  ['files'],
  $netmasks =  ['files'],
  $networks =  ['files'],
  $protocols =  ['files'],
  $rpc =  ['files'],
  $services =  ['files'],
  $netgroup =  ['files'],
  $publickey =  ['nisplus'],
  $automount =  ['files','nisplus'],
  $aliases =  ['files','nisplus'],
  $sudoers = ['files'],
  $use_ldap = defined('$::use_ldap') ? { true => $::use_ldap, default => hiera('use_ldap',false) },
  $use_sssd = $::simplib::params::use_sssd
) inherits ::simplib::params {
  validate_array($passwd)
  validate_array($shadow)
  validate_array($group)
  validate_array($initgroups)
  validate_array($hosts)
  validate_array($bootparams)
  validate_array($ethers)
  validate_array($netmasks)
  validate_array($networks)
  validate_array($protocols)
  validate_array($rpc)
  validate_array($services)
  validate_array($netgroup)
  validate_array($publickey)
  validate_array($automount)
  validate_array($aliases)
  validate_bool($use_ldap)
  validate_bool($use_sssd)

  if $use_ldap {
    if $use_sssd {
      $_use_ldap = false
    }
    else {
      $_use_ldap = $use_ldap
    }
  }
  else {
    $_use_ldap = $use_ldap
  }

  validate_bool($_use_ldap)

  file { '/etc/nsswitch.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('simplib/etc/nsswitch.conf.erb')
  }
}
