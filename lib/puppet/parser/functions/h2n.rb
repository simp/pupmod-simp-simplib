module Puppet::Parser::Functions
  newfunction(:h2n, :type => :rvalue, :doc => <<-EOM) do |args|
    Takes a single `hostname` and returns the associated IP address if it
    can determine it.

    If it cannot be determined, simply returns the passed hostname.

    @return [String]
    EOM

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
      # ignore
    end
    return retval
  end

end
