#
# Class: simplib::at
#
# Manages /etc/at.allow and /etc/at.deny
#
class simplib::at {

  simplib::at::add_user{ 'root': }

  concat_build { 'at':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/at.allow'
  }

  file { '/etc/at.allow':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    subscribe => Concat_build['at'],
    audit     => 'content'
  }

  file { '/etc/at.deny':
    ensure => 'absent'
  }

  service { 'atd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true
  }
}
