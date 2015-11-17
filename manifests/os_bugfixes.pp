# == Class: simplib::os_bugfixes
#
# This class collects Operating System bugfixes and workarounds that do not
# belong specifically in another module.
#
class simplib::os_bugfixes {
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
