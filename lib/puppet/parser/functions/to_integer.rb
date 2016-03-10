module Puppet::Parser::Functions
  newfunction(:to_integer, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Converts the argument into an Integer.

    Only works if the passed argument responds to the 'to_i' Ruby method.
    EOS
  ) do |arguments|

    arg = arguments[0]

    return arg if arg.is_a?(Integer)

    if arg.respond_to?(:to_i)
      return arg.to_i
    else
      raise(Puppet::ParseError, "to_integer(): Object type '#{arg.class}' cannot be converted to an Integer")
    end
  end
end
