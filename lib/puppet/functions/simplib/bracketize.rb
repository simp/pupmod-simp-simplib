# Add brackets to IP addresses and `Arrays` of IP
# addresses based on the rules for bracketing
# IPv6 addresses.
#
# Ignore anything that does not look like an IPv6 address.
#
Puppet::Functions.create_function(:'simplib::bracketize') do

  # @param ipv6 The ipv6 to bracketize
  # @return [Variant[String, Array[String]]] converted input
  #
  # @example Bracketize ipv6 input
  #
  #   $foo = [ '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
  #            '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24' ]
  #
  #   $bar = simplib::bracketize($foo)
  #
  #   $bar contains:[ '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
  #                   '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24' ]
  #
  dispatch :bracketize do
    required_param 'Array[String]', :ipaddr
  end

  dispatch :bracketize_string_input do
    required_param 'String', :ipaddr_string
  end

  def bracketize_string_input(ipaddr_string)
    ipaddr = ipaddr_string.split(/\s|,|;/).delete_if{ |y| y.empty? }
    bracketize(ipaddr)
  end

  def bracketize(ipaddr)
    require 'ipaddr'
    ipaddr = Array(ipaddr).flatten
    retval = Array.new
    ipaddr.each do |x|
      begin
        ip = IPAddr.new(x)
      rescue
        #allowed to fail because input can be string of hostname
        # will just return unaltered input in that case
        retval << x
        next
      end
      # IPv6 Address?
      if ip.ipv6?() then
        if x[0].chr != '[' then
          y = x.split('/')
          y[0] = "[#{y[0]}]"
          retval << y.join('/')
        end
      else
        retval << x
      end
    end

    retval = retval.first if retval.size == 1
    return retval
  end
end
