module Puppet::Parser::Functions
  newfunction(
    :get_ports,
    :type => :rvalue,
    :doc  => <<-EOM) do |args|
      Take an array of items that may contain port numbers and appropriately return
      the port portion. Works with hostnames, IPv4, and IPv6.

      Example:
        $foo = ['https://mysite.net:8443','http://yoursite.net:8081']
        $bar = strip_ports($foo)
        $bar contains: ['8443','8081']

  EOM

    raise Puppet::ParseError, "You must pass a list of hosts." if args.empty?
    Puppet::Parser::Functions.autoloader.loadall

    hosts = Array(args).flatten
    parsed_hosts = function_parse_hosts([hosts])

    ports = []
    for key in parsed_hosts.keys
      ports << parsed_hosts[key][:ports] if not parsed_hosts[key][:ports].nil?
    end

    ports.flatten.uniq
  end
end
