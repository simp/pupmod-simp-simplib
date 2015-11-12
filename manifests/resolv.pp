# _Description_
#
# Configure resolv.conf
#
# See resolv.conf(5) for details on the various options.
#
class simplib::resolv (
# _Variables_
#
# $named_server
#     A boolean that states that this server is definitively a named server.
#     Bypasses the need for $named_autoconf below.
    $named_server = false,
#
# $named_autoconf
#     A boolean that controlls whether or not to autoconfigure named.
#     true => If the server where puppet is being run is in the list of
#             $nameservers then automatically configure named.
#     false => Do not autoconfigure named.
    $named_autoconf = true,
# $nameservers
#     An array of servers to query. If the first server is '127.0.0.1' or '::1'
#     then the host will be set up as a caching DNS server unless $caching is
#     set to false.  The other hosts will be used as the higher level
#     nameservers.
    $nameservers = hiera('dns::servers'),
# $caching
#     *If* the $nameservers array above starts with '127.0.0.1' or '::1', then
#     the system will set itself up as a caching nameserver unless this is set
#     to false.
    $caching = true,
# $resolv_domain
#     Local domain name, defaults to the domain of your host.
    $resolv_domain = $::domain,
# $search
#     Array of entries that will be searched, in order, for hosts.
    $search = hiera('dns::search',[]),
# $sortlist
#     Array of address/netmask pairs that allow addresses returned by
#     gethostbyname to be sorted.
    $sortlist = [],
# $extra_options
#     A place to put any options that may not be covered by the
#     variables below. These will be appended to the options string.
    $extra_options = [],
# The following $option_* entries are described in detail in
# resolv.conf(5)
    $option_debug = false,
    $option_ndots = '1',
    $option_timeout = '2',
    $option_attempts = '2',
    $option_rotate = true,
    $option_no_check_names = false,
    $option_inet6 = false
) {
  validate_bool($named_server)
  validate_bool($named_autoconf)
  validate_array($nameservers)
  validate_bool($caching)
  validate_array($search)
  validate_array($sortlist)
  validate_array($extra_options)
  validate_bool($option_debug)
  validate_integer($option_ndots)
  validate_integer($option_timeout)
  validate_integer($option_attempts)
  validate_bool($option_rotate)
  validate_bool($option_no_check_names)
  validate_bool($option_inet6)

  # If this client is one of these passed IP's, then make it a real DNS server
  if $named_server or (
    defined('named') and defined(Class['named'])
  ) or (
    $named_autoconf and host_is_me($nameservers)
  )
  {
    $l_is_named_server = true
  }

  if $named_autoconf {
    # Having 127.0.0.1 or ::1 first tells us that we want to be a
    # caching DNS server.
    if ! $l_is_named_server and $caching and (
      $nameservers[0] == '127.0.0.1' or
      $nameservers[0] == '::1' )
    {
      if size($nameservers) == 1 {
        fail('If using named as a caching server, 127.0.0.1 must not be your only nameserver entry.')
      }
      else {
        include 'named::caching'

        $l_forwarders = inline_template('<%= @nameservers[1..-1].join(" ") %>')
        named::caching::forwarders { $l_forwarders: }

        File['/etc/resolv.conf'] -> Service['named']
      }
    }
    else {
      if $l_is_named_server {
        include 'named'

        File['/etc/resolv.conf'] -> Service['named']
      }
    }
  }

  # We're managing resolv.conf, so ignore what dhcp says.
  simp_file_line { 'resolv_peerdns':
    path       => '/etc/sysconfig/network',
    line       => 'PEERDNS=no',
    match      => '^\s*PEERDNS=',
    deconflict => true
  }

  if defined(Class['named']) and ! $::named::chroot {
    $bind_pkg = 'bind'
  }
  else {
    $bind_pkg = 'bind-chroot'
  }

  file { '/etc/resolv.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Simp_file_line['resolv_peerdns'],
    content => template('simplib/etc/resolv_conf.erb')
  }
}
