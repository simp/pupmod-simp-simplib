# Class: simplib::incron
#
# This class manages /etc/incron.allow and /etc/incron.deny and the
# incrond service.
#
class simplib::incron {

  simplib::incron::add_user { 'root': }

  simpcat_build { 'incron':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/incron.allow'
  }

  file { '/etc/incron.deny':
    ensure => 'absent'
  }

  package { 'incron':
    ensure => latest
  }

  service { 'incrond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['incron']
  }
}
