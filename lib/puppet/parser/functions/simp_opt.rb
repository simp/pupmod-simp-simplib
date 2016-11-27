module Puppet::Parser::Functions
  newfunction(:simp_opt, :type => :rkey, :arity => 1, :doc => <<-EOS
    Retrieve a SIMP global catalyst.

    Any variable that is passed into this function will look up a variable
    ``simp_opt::<variable>``.

    Example:

    simp_opt('foo::bar') will return the value in the variable ``$simp_opt::foo::bar``
    EOS
  ) do |arguments|

    key = arguments[0]

    unless key.is_a?(String)
      raise(Puppet::ParseError, "simp_opt(): The argument must be a String, got '#{key.class}'")
    end

    key = ['simp_opt', key].join('::')

    # Hack around the inablilty to silence global warnings.
    def self.lookup_global_silent(param)
      find_global_scope.to_hash(param)
    end

    value = lookup_global_silent(key)

    if (!value || value.empty?)
      if self.respond_to?(:call_function)
        begin
          value = call_function('lookup',[key, nil])
        # 3.X doesn't work with the lookup function
        rescue NoMethodError, Puppet::ParseError
          begin
            value = call_function('hiera',[key, nil])
          rescue  NoMethodError
            value = nil
          end
        end
      else
        # Puppet 3.X only
        value = function_hiera([key, nil])
      end
    end

    value
  end
end
