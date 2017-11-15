module Puppet::Parser::Functions
  newfunction(:simplib_deprecation, :doc => <<-'EOS') do |arguments|
    Function to print deprecation warnings for 3.X functions.
    The first argument is the uniqueness key, which allows deduping of messages.
    The second argument is the message to be printed.
    Messages can be enabled if the SIMPLIB_LOG_DEPRECATIONS environment
    variable is set to 'true'.
    @return [Nil]

    @example
      simplib_deprecation('foo', 'foo is deprecated: use simplib::foo instead')

    EOS

    raise(Puppet::ParseError, "deprecation: Wrong number of arguments " +
      "given (#{arguments.size} for 2)") unless arguments.size == 2

    key = arguments[0]
    message = arguments[1]

    if ENV['SIMPLIB_LOG_DEPRECATIONS'] == "true"
      Puppet.deprecation_warning(message, key)
    end
  end
end
