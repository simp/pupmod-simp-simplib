# == Class: simplib::params
#
# A set of defaults for the 'simplib' namespace
#
# $use_sssd
# Default: false on EL<6.7, true otherwise
#   There are issues with ldap and nslcd on EL7+ which can result in users
#   being locked out of the system. SSSD contains a bug which will allow users
#   with a valid SSH key to bypass the password lockout as returned by LDAP but
#   this can be worked around much more easily than the workaround for the ldap
#   issues which significantly weaken your security posture.
class simplib::params {
  if $::operatingsystem in ['RedHat','CentOS'] {
    if versioncmp($::operatingsystemrelease,'6.7') < 0 {
      $_use_sssd = false
    }
    else {
      $_use_sssd = true
    }

    $use_sssd = defined('$::use_sssd') ? {
      true => $::use_sssd,
      default => hiera('use_sssd',$_use_sssd)
    }

    if $::operatingsystemmajrelease == '6' {
      $_install_tmpwatch = true
    }
    else{
     $_install_tmpwatch = false
    }

  }
  else {
    fail("${::operatingsystem} not yet supported by ${module_name}")
  }
}
