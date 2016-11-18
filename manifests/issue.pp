# == Class: simplib::issue
#
# Set the content of /etc/issue and /etc/issue.net
#
# Allows for compliance with CCE-26974-6
#
# == Parameters
#
# [*content*]
# Type: String
# Default: ''
#   If set, will explicitly set the content of /etc/issue to this string and
#   ignore all other options.
#
# [*source*]
# Type: rsync or URI
# Default: 'puppet:///modules/simplib/etc/issue'
#   If set to 'rsync', will work in legacy mode and pull the file over rsync
#   from default/global_etc/issue.
#
#   Otherwise, will treat the string as a URI for the file source for /etc/issue.
#
# [*net_content*]
# Type: String
# Default: ''
#   The same as $content but for /etc/issue.net.
#
# [*net_source*]
# Type: rsync or URI
# Default: 'file:///etc/issue'
#   The same as $source but for /etc/issue.net.
#
# [*rsync_server*]
# Type: FQDN or IP
# Default: hiera('rsync::server','')
#   If rsync is used, must be set to a valid rsync server from which to pull the files.
#
# [*rsync_timeout*]
# Type: Integer
# Default: hiera('rsync::timeout','2')
#   The connection timeout for the rsync connection.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::issue (
  $content = '',
  $source = 'puppet:///modules/simplib/etc/issue',
  $net_content = '',
  $net_source = 'file:///etc/issue',
  $rsync_server = hiera('rsync::server',''),
  $rsync_timeout = hiera('rsync::timeout','2')
){

  $issue_file_base = { owner => 'root', group => 'root', mode  => '0644' }

  if !empty($content) {
    $issue_file = { '/etc/issue' => { content => $content } }
  }
  else {
    if $source == 'rsync' {
      $issue_file = { '/etc/issue' => {} }

      rsync { '/etc/issue':
        source  => 'default/global_etc/issue',
        target  => '/etc/issue',
        server  => $rsync_server,
        timeout => $rsync_timeout
      }

      Rsync['/etc/issue'] -> File['/etc/issue']

      validate_net_list($rsync_server)
    }
    else {
      $issue_file = { '/etc/issue' => { source => $source } }
    }
  }

  create_resources( file, $issue_file, $issue_file_base )

  # This could be done with a define but why add the complexity for only one
  # file?

  $issue_net_file_base = { owner => 'root', group => 'root', mode  => '0644' }

  if !empty($net_content) {
    $issue_net_file = { '/etc/issue.net' => { content => $net_content } }
  }
  else {
    if $net_source == 'rsync' {
      $issue_net_file = { '/etc/issue.net' => {} }

      rsync { '/etc/issue.net':
        source  => 'default/global_etc/issue.net',
        target  => '/etc/issue.net',
        server  => $rsync_server,
        timeout => $rsync_timeout
      }

      Rsync['/etc/issue.net'] -> File['/etc/issue.net']

      validate_net_list($rsync_server)
    }
    else {
      $issue_net_file = { '/etc/issue.net' => { source => $net_source } }

      File['/etc/issue'] -> File['/etc/issue.net']
    }
  }

  create_resources( file, $issue_net_file, $issue_net_file_base )

}
