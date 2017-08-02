module Puppet::Parser::Functions
  newfunction(:array_include, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Determine if the first passed array contains the contents of another array or string.

    @example

      $arr_x = [ 'foo', 'bar' ]
      $arr_y = [ 'foo', 'baz', 'bar' ]

      if array_include($arr_x, $arr_y) {
        notice('this will be printed')
      }
      if array_include($arr_x, 'bar') {
        notice('this will be printed')
      }
      if array_include($arr_x, 'baz') {
        notice('this will not be printed')
      }

    @return [Boolean]

    ENDHEREDOC

    unless args.length == 2
      raise Puppet::ParseError, ("array_include(): wrong number of arguments (#{args.length}; must be 2)")
    end
    unless args[0].is_a?(Array)
      raise Puppet::ParseError, "array_include(): expects the first argument to be an array, got #{args[0].inspect} which is of type #{args[0].class}"
    end
    unless args[1].is_a?(Array) or args[1].is_a?(String)
      raise Puppet::ParseError, "array_include(): expects the second argument to be an array or string, got #{args[0].inspect} which is of type #{args[0].class}"
    end

    retval = false

    retval = true if (Array(args[1]) - args[0]).empty?

    retval

  end

end
