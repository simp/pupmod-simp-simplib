module Puppet::Parser::Functions
  # This function takes a single hostname and returns the associated IP address
  # if it can determine it. If it cannot be determined, it simply returns the
  # hostname.

  newfunction(:h2n, :type => :rvalue, :doc => "Return an IP address for the passed hostname.") do |args|
    require 'resolv'

    to_find = args.first.to_s
    retval = to_find

    if not to_find.include?('.') and not lookupvar('::domain').empty? then
      to_find = "#{to_find}.#{lookupvar('::domain')}"
    end

    begin
      Timeout::timeout(2) do
        retval = Resolv::DNS.new().getaddress(to_find).to_s
      end
    rescue Timeout::Error, Resolv::ResolvError
    end
    return retval
  end

end
