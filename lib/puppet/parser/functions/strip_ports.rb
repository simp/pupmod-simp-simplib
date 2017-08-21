module Puppet::Parser::Functions
  newfunction(:strip_ports, :type => :rvalue, :doc => <<-EOM) do |args|
    Take an `Array` of items that may contain port numbers and appropriately
    return the non-port portion. Works with hostnames, IPv4, and IPv6.

    @example

      $foo = ['https://mysite.net:8443',
              'http://yoursite.net:8081',
              'https://theirsite.com']

      $bar = strip_ports($foo)

      $bar contains: ['https://mysite.net','http://yoursite.net','theirsite.com']

    @param hosts [Array[String]]
      `Array` of hostnames which may contain port numbers.

    @return [Array[String]]
  EOM

    function_simplib_deprecation(['strip_ports', 'strip_ports is deprecated, please use simplib::strip_ports'])

    raise Puppet::ParseError, "You must pass a list of hosts." if args.empty?
    Puppet::Parser::Functions.autoloader.loadall

    hosts = Array(args).flatten
    stripped_hosts = function_parse_hosts([hosts]).keys.uniq

    stripped_hosts.uniq
  end
end
