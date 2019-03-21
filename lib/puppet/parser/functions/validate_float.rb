module Puppet::Parser::Functions
  newfunction(:validate_float, :doc => <<-EOS) do |args|
    Validates whether or not the passed argument is a float

    @return [Nil]
    EOS

    function_simplib_deprecation(['validate_float', 'validate_float is deprecated and will be removed in a future release'])

    if (args.size != 1)
      raise(Puppet::ParseError, "is_float(): Wrong number of args "+
        "given #{args.size} for 1")
    end

    value = "#{args[0]}"

    if value != value.to_f.to_s.sub(/\.0$/,'')
      raise Puppet::ParseError, ("'#{args}' is not a float.")
    end
  end
end
