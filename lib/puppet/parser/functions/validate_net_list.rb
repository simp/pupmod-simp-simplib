module Puppet::Parser::Functions
  newfunction(:validate_net_list, :doc => <<-'ENDHEREDOC') do |args|
    Validate that a passed list (`Array` or single `String`) of networks is
    filled with valid IP addresses or hostnames. Hostnames are checked per
    RFC 1123. Ports appended with a colon `:` are allowed.

    There is a second, optional argument that is a regex of `Strings` that
    should be ignored from the list. Omit the beginning and ending `/`
    delimiters.

    @example Passing

      $trusted_nets = ['10.10.10.0/24','1.2.3.4','1.3.4.5:400']
      validate_net_list($trusted_nets)

      $trusted_nets = '10.10.10.0/24'
      validate_net_list($trusted_nets)

      $trusted_nets = ['10.10.10.0/24','1.2.3.4','%any','ALL']
      validate_net_list($trusted_nets,'^(%any|ALL)$')

    @example Failing

      $trusted_nets = '10.10.10.0/24,1.2.3.4'
      validate_net_list($trusted_nets)

      $trusted_nets = 'bad stuff'
      validate_net_list($trusted_nets)

    @return [Nil]
    ENDHEREDOC

    function_simplib_deprecation(['validate_net_list', 'validate_net_list is deprecated, please use simplib::validate_net_list'])

    if ((args.length < 1) || (args.length > 2))
      raise Puppet::ParseError,("validate_net_list(): Must pass [net_list], (optional exclusion regex).")
    end

    net_list = args.shift
    unless (net_list.is_a?(String) || net_list.is_a?(Array))
      raise Puppet::ParseError,("validate_net_list(): net_list must be either a String or Array")
    end
    net_list = Array(net_list.dup)

    str_match = args.shift

    if str_match
      # hack to be backward compatible
      local_str_match = str_match.dup
      local_str_match = '\*' if local_str_match == '*'

      local_str_match = Regexp.new(local_str_match)
      net_list.delete_if{|x| local_str_match.match(x)}
    end

    require File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')
    require 'ipaddr'

    # Needed to use other functions inside of this one
    Puppet::Parser::Functions.autoloader.loadall

    net_list.each do |net|
      # Do we have a port?
      host,port = PuppetX::SIMP::Simplib.split_port(net)
      function_validate_port(Array(port)) if (port && !port.empty?)

      # Valid quad-dotted IPv4 addresses will validate as hostnames.
      # So check for IP addresses first
      begin
        IPAddr.new(host)
      # For some reason, can't see derived error class (IPAddr::Error)
      # when run by Puppet
      rescue ArgumentError
        # if looks like quad-dotted set of decimal numbers, most likely
        # it is not an oddly-named host, but a bad IPv4 address in which
        # one or more of the octets is out of range (configuration
        # fat-finger....)
        if host.match(/^([0-9]+)(\.[0-9]+){3}$/)
          raise Puppet::ParseError,("validate_net_list(): '#{net}' is not a valid network.")
        end

        # assume OK if this looks like hostname
        unless PuppetX::SIMP::Simplib.hostname_only?(host)
          raise Puppet::ParseError,("validate_net_list(): '#{net}' is not a valid network.")
        end
      end
    end
  end
end
