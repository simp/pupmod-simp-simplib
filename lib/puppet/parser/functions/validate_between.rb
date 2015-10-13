module Puppet::Parser::Functions

  newfunction(:validate_between, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the first value is between the second and third
    values numerically.

    This is a pure Ruby comparison, not a human comparison.

    ENDHEREDOC

    unless Array(args).length == 3 then
      raise Puppet::ParseError, ("validate_between() takes exactly three arguments")
    end

    args[0].between?(args[1],args[2])

  end

end
