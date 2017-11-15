module Puppet::Parser::Functions
  newfunction(:validate_bool_simp, :doc => <<-'ENDHEREDOC') do |args|
    Validate that all passed values are either `true` or `false`.

    Abort catalog compilation if any value fails this check.

    Modified from the stdlib validate_bool to handle the strings `true` and
    `false`.

    @example

      The following values will pass:

        $iamtrue = true
        validate_bool(true)
        validate_bool("false")
        validate_bool("true")
        validate_bool(true, 'true', false, $iamtrue)

      The following values will fail, causing compilation to abort:

        $some_array = [ true ]
        validate_bool($some_array)

    @return [Nil]
    ENDHEREDOC

    function_simplib_deprecation(['validate_bool_simp', 'validate_bool_simp is deprecated, please use simplib::validate_bool'])

    unless args.length > 0 then
      raise Puppet::ParseError, ("validate_bool(): wrong number of arguments (#{args.length}; must be > 0)")
    end

    valid_entries = [true, false, 'true', 'false']
    args.each do |arg|
      unless valid_entries.include?(arg) then
        raise Puppet::ParseError, ("'#{arg}' is not a boolean.")
      end
    end
  end
end
