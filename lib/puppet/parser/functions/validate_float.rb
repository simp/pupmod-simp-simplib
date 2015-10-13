module Puppet::Parser::Functions
  newfunction(:validate_float, :doc => <<-EOS
      Validates whether or not the passed argument is a float.
    EOS
  ) do |arguments|

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "is_float(): Wrong number of arguments "+
        "given #{arguments.size} for 1")
    end

    value = "#{arguments[0]}"

    if value != value.to_f.to_s.sub(/\.0$/,'') then
      raise Puppet::ParseError, ("'#{arguments}' is not a float.")
    end

  end
end

# vim: set ts=2 sw=2 et :
