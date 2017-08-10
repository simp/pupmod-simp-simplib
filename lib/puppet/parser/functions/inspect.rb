module Puppet::Parser::Functions
  newfunction(:inspect, :doc => <<-EOM) do |args|
    Prints out Puppet warning messages that display the passed variable.

    This is mainly meant for debugging purposes.

    @return [Nil]
    EOM

    function_simplib_deprecation(['inspect', 'inspect is deprecated, please use simplib::inspect'])

    if (args.size != 1)
      raise(Puppet::ParseError, "inspect(): Wrong number of arguments "+
        "given #{args.size} for 1")
    end

    puts("Inspect: Type => '#{args.first.class}' Content => '#{args.first.to_pson}'")
    Puppet.warning("Inspect: Type => '#{args.first.class}' Content => '#{args.first.to_pson}'")
  end
end
