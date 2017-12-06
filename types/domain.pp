# Valid DNS domain names
#
# Complies with TLD restrictions from Section 2 of RFC 3696:
#
#  * only ASCII alpha + numbers + hyphens are allowed
#  * labels can't begin or end with hyphens
#  * TLDs cannot be all-numeric
#
type Simplib::Domain = Pattern['^(?i-mx:(?=^.{1,253}$)((?!-)[a-z0-9-]+(?<!-)\.)*(?!-|\d+$)([a-z0-9-]+)(?<!-))$']
