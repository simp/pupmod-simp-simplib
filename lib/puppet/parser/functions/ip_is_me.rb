module Puppet::Parser::Functions
  # This has been left in place for backward compatiblity.

  newfunction(:ip_is_me, :type => :rvalue, :doc => <<-EOM) do |args|
    Detect if an IP address is contained in the passed whitespace delimited
    `String`.

    @return [Boolean]
    EOM

    Puppet::Parser::Functions.autoloader.load(
      File.expand_path(File.dirname(__FILE__) + '/host_is_me.rb')
    )
    require 'ipaddr'

    if args.class.eql?(Array) then
      f_args = args.dup
    else
      f_args = args.split(/\s/)
    end

    f_args << "127.0.0.1"
    f_args << "::1"
    f_args.delete_if { |x|
      retval=true
      begin
        IPAddr.new(x)
      rescue ArgumentError
        retval=false
      end
      retval
    }

    function_host_is_me(f_args)
  end
end
