# Take an input list of networks and returns an equivalent `Array` in
# CIDR notation.
# Hostnames are passed through untouched.
Puppet::Functions.create_function(:'simplib::nets2cidr') do

  # @param network_list List of 1 or more networks separated by spaces,
  #   commas, or semicolons
  # @return [Array[String]] Array of networks in CIDR notation
  dispatch :nets2cidr_list do
    required_param 'String', :network_list
  end

  # @param networks Array of networks
  # @return [Array[String]] Array of networks in CIDR notation
  dispatch :nets2cidr do
    required_param 'Array', :networks
  end

  def nets2cidr_list(network_list)
    networks = network_list.split(/\s|,|;/).delete_if{ |y| y.empty? }
    nets2cidr(networks)
  end

  def nets2cidr(networks)

    require  File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')
    require 'ipaddr'

    retval = Array.new
    networks.each do |lnet|
      # Skip any hostnames that we find.
      if PuppetX::SIMP::Simplib.hostname_only?(lnet)
        retval << lnet
        next
      end

      begin
        ipaddr = IPAddr.new(lnet)
      rescue
        fail("simplib::nets2cidr: '#{lnet}' is not a valid network!")
      end

      # Just add it if it doesn't have a specified netmask.
      if lnet =~ /\//
        retval << "#{ipaddr.to_s}/#{IPAddr.new(ipaddr.inspect.split('/').last.chop).to_i.to_s(2).count('1')}"
      else
        retval << lnet
      end
    end
    retval
  end
end
