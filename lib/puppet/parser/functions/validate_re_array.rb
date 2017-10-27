module Puppet::Parser::Functions
  # Derived from the Puppet Labs stdlib validate_re
  newfunction(:validate_re_array, :doc => <<-'ENDHEREDOC') do |args|
    Perform simple validation of a `String`, or `Array` of `Strings`,
    against one or more regular expressions. The first argument of
    this function should be a `String` to test, and the second argument
    should be a stringified regular expression (without the `//`
    delimiters) or an `Array` of regular expressions.  If none of the regular
    expressions match the string passed in, compilation will abort with a parse
    error.

    If a third argument is specified, this will be the error message raised and
    seen by the user.

    @example Passing
      validate_re_array('one', '^one$')
      validate_re_array('one', [ '^one', '^two' ])
      validate_re_array(['one','two'], [ '^one', '^two' ])

    @example Failing
      validate_re_array('one', [ '^two', '^three' ])

    @example Custom Error Message
      validate_re_array($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')

    @return [Nil]
    ENDHEREDOC

    function_simplib_deprecation(['validate_re_array', 'validate_re_array is deprecated, please use simplib::validate_re_array'])

    if (args.length < 2) or (args.length > 3) then
      raise Puppet::ParseError, ("validate_re_array(): wrong number of arguments (#{args.length}; must be 2 or 3)")
    end

    msg = "Oops, there's an error in validate_re_array!"

    Array(args[0]).each do |to_check|
      msg = args[2] || "validate_re_array(): #{to_check.inspect} does not match #{args[1].inspect}"

      valid = false
      Array(args[1]).each do |re_str|
        if "#{to_check}" =~ Regexp.compile(re_str) then
          valid = true
          break
        end
      end

      # Bail at the first failure.
      raise Puppet::ParseError, (msg) unless valid
    end

  end
end
