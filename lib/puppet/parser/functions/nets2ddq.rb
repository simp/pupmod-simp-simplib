module Puppet::Parser::Functions
  # This function takes an input array of networks and returns an equivalent
  # array in dotted quad notation.
  # It can also accept a string separated by spaces, commas, or semicolons.

  newfunction(:nets2ddq, :type => :rvalue, :doc => <<-EOM) do |args|
    Take an input `Array` of networks and returns an equivalent `Array` in
    Dotted Quad notation.

    It can also accept a `String` separated by spaces, commas, or semicolons.

    @param networks [Variant[Array[String], String]]

    @return [Variant[Array[String], String]]
    EOM

    function_simplib_deprecation(['nets2ddq', 'nets2ddq is deprecated, please use simplib::nets2ddq'])

    require File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')

    networks = Array(args.dup).flatten
    retval = Array.new

    # Try to be smart about pulling the string apart.
    networks = networks.map{|x|
      if !x.is_a?(Array) then
        x = x.split(/\s|,|;/).delete_if{ |y| y.empty? }
      end
    }.flatten

    networks.each do |lnet|
      begin
        ipaddr = IPAddr.new(lnet)
      rescue
        if PuppetX::SIMP::Simplib.hostname?(lnet) then
          retval << lnet
          next
        end
        raise Puppet::ParseError,"nets2ddq: #{lnet} is not a valid IP address!"
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
