module Puppet::Parser::Functions
  newfunction(
    :parse_hosts,
    :type => :rvalue,
    :doc  => <<-EOM) do |args|
       Take an array of items that may contain port numbers or protocols and
       return the host information, ports, and protocols.  Works with
       hostnames, IPv4, and IPv6.

       Example:

        parse_hosts([
          '1.2.3.4',
          'http://1.2.3.4',
          'https://1.2.3.4:443'
        ])

       Returns:
        {
         '1.2.3.4' => {
           :ports     => ['443'],
           :protocols => {
             'http'  => [],
             'https' => ['443']
           }
        }

       NOTE: IPv6 addresses will be returned normalized with square brackets
             around them for clarity.
    EOM

    # Defaults
    hosts = args.flatten

    # Validation
    raise Puppet::ParseError, "You must pass a list of hosts." if hosts.empty?

    # Needed to use other functions inside of this one
    Puppet::Parser::Functions.autoloader.loadall

    # Parse!
    parsed_hosts = {}
    hosts.each do |host|

      host = host.strip

      next if host.nil? || host.empty?
      tmp_host = host

      # Initialize.
      protocol = nil
      port = nil
      hostname = nil

      # Get the protocol.
      tmp_host = host.split('://')
      if tmp_host.size == 1
        hostname = tmp_host.first
      else
        protocol = tmp_host.first
        hostname = tmp_host.last
      end

      # Validate with the protocol stripped off
      function_validate_net_list(Array(hostname))

      hostname,port = PuppetX::SIMP::Simplib.split_port(hostname)
      function_validate_port(Array(port)) if (port && !port.empty?)

      # Build a unique list of parsed hosts.
      unless parsed_hosts.key?(hostname)
        parsed_hosts[hostname] = {
          :ports     => [],
          :protocols => {}
        }
      end

      if port
        parsed_hosts[hostname][:ports] << port
      end

      if protocol
        parsed_hosts[hostname][:protocols] = {} unless parsed_hosts[hostname][:protocols]
        parsed_hosts[hostname][:protocols][protocol] = [] unless parsed_hosts[hostname][:protocols][protocol]

        parsed_hosts[hostname][:protocols][protocol] << port if port
      end
    end

    parsed_hosts.keys.each do |host|
      unless parsed_hosts[host][:ports].empty?
        parsed_hosts[host][:ports].uniq!
        parsed_hosts[host][:ports].sort!
      end

      parsed_hosts[host][:protocols].each_key do |protocol|
        unless parsed_hosts[host][:protocols][protocol].empty?
          parsed_hosts[host][:protocols][protocol].uniq!
          parsed_hosts[host][:protocols][protocol].sort!
        end
      end
    end

    parsed_hosts
  end
end
