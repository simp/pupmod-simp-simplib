module Puppet::Parser::Functions
  # This function takes an input array of networks and returns an equivalent
  # array in CIDR notation.
  # It can also accept a string separated by spaces, commas, or semicolons.

  newfunction(
    :nets2cidr,
    :type => :rvalue,
    :doc => "Convert an array of networks into CIDR notation"
  ) do |args|
    require  File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')

    networks = Array(args.dup).flatten
    retval = Array.new

    # Try to be smart about pulling the string apart.
    networks = networks.map{|x|
      if !x.is_a?(Array) then
        x = x.split(/\s|,|;/).delete_if{ |y| y.empty? }
      end
    }.flatten

    networks.each do |lnet|
      # Skip any hostnames that we find.
      if PuppetX::SIMP::Simplib.hostname?(lnet) then
        retval << lnet
        next
      end

      begin
        ipaddr = IPAddr.new(lnet)
      rescue
        raise Puppet::ParseError,"nets2cidr: #{lnet} is not a valid IP address!"
      end

      # Just add it if it doesn't have a specified netmask.
      if lnet =~ /\// then
        retval << "#{ipaddr.to_s}/#{IPAddr.new(ipaddr.inspect.split('/').last.chop).to_i.to_s(2).count('1')}"
      else
        retval << lnet
      end
    end
    retval
  end
end
