module Puppet::Parser::Functions
  newfunction(:validate_integer, :doc => <<-EOS) do |args|
    Validates that the passed argument is an `Integer`.

    @return [Nil]
    EOS

    if (args.size != 1)
      raise(Puppet::ParseError, "is_integer(): Wrong number of args given #{args.size} for 1")
    end

    value = "#{args[0]}"

    if value != value.to_i.to_s
      raise Puppet::ParseError, ("'#{args}' is not an integer.")
    end
  end
end
