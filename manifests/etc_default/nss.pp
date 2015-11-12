# _Description_
#
# Install and configure the NSS configuration file.
# See nss(5) for more details.
#
# _Templates_
#
# * etc_default/nss.erb
class simplib::etc_default::nss (
  $netid_authoritative = false,
  $services_authoritative = false,
  $setent_batch_read = true
){

  file { '/etc/default/nss':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('simplib/etc/default/nss.erb')
  }

  validate_bool($netid_authoritative)
  validate_bool($services_authoritative)
  validate_bool($setent_batch_read)
}
