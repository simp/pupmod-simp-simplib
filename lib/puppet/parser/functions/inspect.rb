module Puppet::Parser::Functions
  newfunction(:inspect, :doc => <<-EOS
      Prints out Puppet warning messages that display the passed variable.

      This is mainly meant for debugging purposes.
    EOS
  ) do |args|

    if (args.size != 1) then
      raise(Puppet::ParseError, "inspect(): Wrong number of arguments "+
        "given #{args.size} for 1")
    end

    puts("Inspect: Type => '#{args.first.class}' Content => '#{args.first.to_pson}'")
    Puppet.warning("Inspect: Type => '#{args.first.class}' Content => '#{args.first.to_pson}'")
  end
end

# vim: set ts=2 sw=2 et :
