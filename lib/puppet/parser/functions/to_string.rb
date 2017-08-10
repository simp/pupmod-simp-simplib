module Puppet::Parser::Functions
  newfunction(:to_string, :type => :rvalue, :arity => 1, :doc => <<-EOS) do |arguments|
    Converts the argument into a `String`.

    Only works if the passed argument responds to the `to_s()` Ruby method.

    @param input [Any]
      The argument to convert into a `String`

    @return [String]
    EOS

    function_simplib_deprecation(['to_string', 'to_string is deprecated, please use simplib::to_string'])

    arg = arguments[0]

    return arg if arg.is_a?(String)

    if arg.respond_to?(:to_s)
      return arg.to_s
    else
      raise(Puppet::ParseError, "to_string(): Object type '#{arg.class}' cannot be converted to a String")
    end
  end
end
