module Puppet::Parser::Functions
  newfunction(
    :strip_ports,
    :type => :rvalue,
    :doc  => <<-EOM) do |args|
       Take an array of items that may contain port numbers and appropriately return
       the non-port portion. Works with hostnames, IPv4, and IPv6.

       Example:

       $foo = ['https://mysite.net:8443',
               'http://yoursite.net:8081',
               'https://theirsite.com']

       $bar = strip_ports($foo)

       $bar contains: ['https://mysite.net','http://yoursite.net','theirsite.com']

      Arguments: hosts
        - 'hosts'        => Array of hostnames which may contain port numbers.
  EOM

    raise Puppet::ParseError, "You must pass a list of hosts." if args.empty?
    Puppet::Parser::Functions.autoloader.loadall

    hosts = Array(args).flatten
    stripped_hosts = function_parse_hosts([hosts]).keys.uniq

    stripped_hosts.uniq
  end
end
