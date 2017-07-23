module Puppet::Parser::Functions
  newfunction(:array_union, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Return the union of two `Arrays`.

    @example

      $arr_x = ['1','2']
      $arr_y = ['2','3','4']

      $res = array_union($arr_x, $arr_y)

      $res contains:
        ['1','2','3','4']

    @return [Array]
    ENDHEREDOC

    unless args.length == 2
      raise Puppet::ParseError, ("array_union(): wrong number of arguments (#{args.length}; must be 2)")
    end
    unless args[0].is_a?(Array) or args[0].is_a?(String)
      raise Puppet::ParseError, "array_union(): expects the first argument to be an array or string, got #{args[0].inspect} which is of type #{args[0].class}"
    end
    unless args[1].is_a?(Array) or args[0].is_a?(String)
      raise Puppet::ParseError, "array_union(): expects the second argument to be an array or string, got #{args[1].inspect} which is of type #{args[1].class}"
    end

    Array(args[0]) | Array(args[1])

  end

end
