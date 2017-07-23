module Puppet::Parser::Functions
  newfunction(:array_size, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns the number of elements in an `Array`. If a `String` is passed,
      simply returns `1`.

    This is in contrast to the Puppet Labs `stdlib` `size()` function which
    returns the size of an `Array` or the length of a `String` when called.

    @return [Integer]
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("array_size(): Exactly one argument must be passed.")
    end
    unless args[0].is_a?(Array) or args[0].is_a?(String)
      raise Puppet::ParseError, "array_size(): expects an Array or String, got a '#{args[0].class}'"
    end

    Array(args[0]).size
  end

end
