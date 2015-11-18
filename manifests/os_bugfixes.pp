# == Class: simplib::os_bugfixes
#
# This class collects Operating System bugfixes and workarounds that do not
# belong specifically in another module.
#
# === Params
#
# [*include_bugfix1049656*]
# Type: Boolean
# Default: true
#   A workaround for the case where EL7 does not always properly run a
#   filesystem relabel if the /.autorelabel file is present.
#
#   See: https://bugzilla.redhat.com/show_bug.cgi?id=1049656
# 
class simplib::os_bugfixes (
  $include_bugfix1049656 = true
) {

  validate_bool($include_bugfix1049656)

  if $include_bugfix1049656 {
    if $::operatingsystem in ['CentOS','RedHat'] {
      if $::operatingsystemmajrelease == '7' {
        file { '/etc/init.d/bugfix1049656':
          ensure => 'file',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          source => "puppet:///modules/${module_name}/etc/init.d/bugfix1049656"
        }
  
        service { 'bugfix1049656':
          enable => true
        }
      }
    }
  }
  else {
    file { '/etc/init.d/bugfix1049656':
      ensure  => 'absent',
      require => Service['bugfix1049656']
    }

    service { 'bugfix1049656': enable => false }
  }
}
