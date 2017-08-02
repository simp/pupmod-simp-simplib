module Puppet::Parser::Functions
  newfunction(:validate_array_of_hashes, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the passed argument is either an empty `Array` or an
    `Array` that only contains `Hashes`.

    @example

      validate_array_of_hashes([{'foo' => 'bar'}])  => OK
      validate_array_of_hashes([])                  => OK
      validate_array_of_hashes(['FOO','BAR'])       => BAD

    @return [Boolean]
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("validate_array_of_hashes(): expects exactly one argument. Got '#{args.length}'")
    end

    valid = true
    to_check = args[0]

    if not to_check.is_a?(Array) then
      valid = false
    else
      to_check.each do |entry|
        next if entry.is_a?(Hash)

        valid = false
        break
      end
    end

    unless valid
      require 'pp'
      raise Puppet::ParseError, ("validate_array_of_hashes(): '#{PP.singleline_pp(to_check,"")}' is not an array of hashes.")
    end
  end
end
