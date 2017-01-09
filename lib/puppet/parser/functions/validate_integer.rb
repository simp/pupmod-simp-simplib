module Puppet::Parser::Functions
  newfunction(:validate_integer, :doc => <<-EOS
      Validates whether or not the passed argument is an integer.
    EOS
  ) do |arguments|

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "is_integer(): Wrong number of arguments "+
        "given #{arguments.size} for 1")
    end

    value = "#{arguments[0]}"

    if value != value.to_i.to_s then
      raise Puppet::ParseError, ("'#{arguments}' is not an integer.")
    end

  end
end
