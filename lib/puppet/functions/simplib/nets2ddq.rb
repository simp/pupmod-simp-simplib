# Tranforms a list of networks into an equivalent array in
# dotted quad notation.
#
# CIDR networks are converted to dotted quad notation networks.
# IP addresses and hostnames are left untouched.

Puppet::Functions.create_function(:'simplib::nets2ddq') do

  # @param networks The networks to convert
  # @return [Array[String]] Converted input
  # @raise RuntimeError if any input item is not a valid network
  #   or hostname
  #
  # @example Convert Array input
  #
  #   $foo = [ '10.0.1.0/24',
  #            '10.0.2.0/255.255.255.0',
  #            '10.0.3.25',
  #            'myhost' ]
  #
  #   $bar = simplib::nets2ddq($foo)
  #
  #   $bar contains:[ '10.0.1.0/255.255.255.0',
  #                   '10.0.2.0/255.255.255.0',
  #                   '10.0.3.25',
  #                   'myhost' ]
  #
  dispatch :nets2ddq do
    required_param 'Array', :networks
  end

  # @param networks_string String containing the list of networks to
  #   convert; list elements are separated by spaces, commas or semicolons.
  # @return [Array[String]] Converted input
  # @raise RuntimeError if any input item is not a valid network
  #   or hostname
  #
  # @example Convert String input
  #
  #   $foo = '10.0.1.0/24 10.0.2.0/255.255.255.0 10.0.3.25 myhost'
  #
  #   $bar = simplib::nets2ddq($foo)
  #
  #   $bar contains:[ '10.0.1.0/255.255.255.0',
  #                   '10.0.2.0/255.255.255.0',
  #                   '10.0.3.25',
  #                   'myhost' ]
  #
  dispatch :nets2ddq_string_input do
    required_param 'String', :networks_string
  end

  def nets2ddq_string_input(networks_string)
    networks = networks_string.split(/\s|,|;/).delete_if{ |y| y.empty? }
    nets2ddq(networks)
  end

  def nets2ddq(networks)
    require 'ipaddr'
    require File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')

    retval = Array.new
    networks.each do |lnet|
      begin
        ipaddr = IPAddr.new(lnet)
      rescue
        if PuppetX::SIMP::Simplib.hostname?(lnet) then
          retval << lnet
          next
        end
        fail("simplib::nets2ddq(): '#{lnet}' is not a valid network.")
      end

      # Just add it if it doesn't have a specified netmask.
      if lnet =~ /\// then
        retval << "#{ipaddr.to_s}/#{ipaddr.inspect.split('/').last.chop}"
      else
        retval << lnet
      end
    end
    retval
  end
end
