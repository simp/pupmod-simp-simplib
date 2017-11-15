module Puppet::Parser::Functions

  newfunction(:validate_array_member, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the first `String` (or `Array`) passed is a member of the
    second `Array` passed. An optional third argument of i can be passed,
    which ignores the case of the objects inside the `Array`.

    @example

      validate_array_member('foo',['foo','bar'])     # => true
      validate_array_member('foo',['FOO','BAR'])     # => false

      #Optional 'i' as third object, ignoring case of FOO and BAR#

      validate_array_member('foo',['FOO','BAR'],'i') # => true

    @return [Boolean]
    ENDHEREDOC

    function_simplib_deprecation(['validate_array_member', 'validate_array_member is deprecated, please use simplib::validate_array_member'])

    unless args.length == 2 or args.length == 3
      raise Puppet::ParseError, ("validate_array_member(): expects two or three arguments. Got '#{args.length}'")
    end

    to_compare = Array(args[0]).dup
    target_array = Array(args[1]).dup
    modifier = args[2]

    if modifier then
      if modifier == 'i' then
        to_compare.map!{|x|
          if x.is_a?(String) then
            x = x.downcase
          else
            x = x
          end
          x
        }
        target_array.map!{|x|
          if x.is_a?(String) then
            x = x.downcase
          else
            x = x
          end
          x
        }
      end
    end

    unless (to_compare - target_array).empty?
      raise Puppet::ParseError, ("validate_array_member(): '#{Array(args[1]).join(',')}' does not contain '#{Array(args[0]).join(',')}'.")
    end

  end

end
