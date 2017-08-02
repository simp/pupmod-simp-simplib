# Provides a reasonable LDAP Base DN as generated from the ``domain`` fact
#
# @param domain
#   The domain to convert
#
# @return [String]
function simplib::ldap::domain_to_dn (
  String $domain = $facts['domain']
) {
  join(split($domain,'\.').map |$x| { "DC=${x}" }, ',')
}
