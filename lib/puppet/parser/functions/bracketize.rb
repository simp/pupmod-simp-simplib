# Add brackets to IP addresses and arrays of IP addresses based on the
# rules for bracketing IPv6 addresses.
#
# Ignore anything that doesn't look like an IPv6 address.
module Puppet::Parser::Functions
  newfunction(:bracketize, :type => :rvalue) do |ipaddr|
    ipaddr = Array(ipaddr).flatten
    toret = ipaddr.map { |x|
      # IPv6 Address?
      if x.include?(':') and x !~ /\./ then
        if x[0].chr != '[' then
          y = x.split('/')
          y[0] = "[#{y[0]}]"
          y.join('/')
        end
      else
        x
      end
    }

    toret = toret.first if toret.size == 1
    return toret
  end
end
