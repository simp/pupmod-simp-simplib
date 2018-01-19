# Provides a LDAP Base DN as generated from the ``domain`` fact
#
# @param domain
#   The domain to convert
#
# @param downcase_attributes
#   Whether or not to downcase the LDAP attributes
#
#     * Different tools have bugs where can can, or cannot, handle upcased (or
#       downcased) LDAP attribute elements
#
# @return [String]
function simplib::ldap::domain_to_dn (
  String $domain               = $facts['domain'],
  Boolean $downcase_attributes = false
) {
  if $downcase_attributes {
    $_dc = 'dc'
  }
  else {
    $_dc = 'DC'
  }

  join(split($domain,'\.').map |$x| { "${_dc}=${x}" }, ',')
}
