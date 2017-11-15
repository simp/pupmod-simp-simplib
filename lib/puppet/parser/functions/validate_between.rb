module Puppet::Parser::Functions
  newfunction(:validate_between, :arity => 3, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the first value is between the second and third values
    numerically.

    This is a pure Ruby comparison, **not** a human comparison.

    @return [Boolean]
    ENDHEREDOC

    function_simplib_deprecation(['validate_between', 'validate_between is deprecated, please use simplib::validate_between'])


    args[0].to_s.between?(args[1].to_s, args[2].to_s)
  end

end
