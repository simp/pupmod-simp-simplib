#
# == Class: simplib::cron
#
# Manage cron-related items on the system.
#
# == Parameters
#
# [*use_rsync*]
# Type: Boolean
# Default: true
#   If true, rsync cron related materials.
#
# [*rsync_root*]
# Type: Rsync Path
# Default: 'default/global_etc'
#   Set the root under which to pull anacrontab, crontab, and cron.*
#
# [*rsync_server*]
# Type: Host or IP
# Default: hiera('rsync::server','')
#   The Rsync Server
#
# [*rsync_timeout*]
# Type: Integer
# Default: hiera('rsync::timeout','2')
#   The Rsync connection timeout
#
# [*install_tmpwatch*]
# Type: Boolean
# Default: false
#   If host is EL6, install the tmpwatch package
#
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::cron (
  $use_rsync = true,
  $rsync_root = 'default/global_etc',
  $rsync_server = hiera('rsync::server',''),
  $rsync_timeout = hiera('rsync::timeout','2'),
  $install_tmpwatch = $::simplib::params::install_tmpwatch,
) inherits simplib::params {
  validate_bool($use_rsync)

  compliance_map()

  if !empty($rsync_server) { validate_net_list($rsync_server) }

  simplib::cron::add_user{ 'root': }

  simpcat_build { 'cron':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/cron.allow'
  }

  file { '/etc/cron.allow':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    audit     => 'content',
    subscribe => Simpcat_build['cron']
  }

  file { '/etc/cron.deny':
    ensure => 'absent'
  }

  if $use_rsync {
    rsync { 'cron':
      source  => "${rsync_root}/cron.*",
      target  => '/etc',
      server  => $rsync_server,
      timeout => $rsync_timeout
    }
  }

  # CCE-27070-2
  service { 'crond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }

  if $install_tmpwatch {
    package { 'tmpwatch': ensure => latest }
  }
}
