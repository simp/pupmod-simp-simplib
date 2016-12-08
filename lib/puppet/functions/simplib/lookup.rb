# A function for falling back to global scope variable lookups when the
# Puppet 4 ``lookup()`` function cannot find a value.
#
# While ``lookup()`` will stop at the back-end data sources, ``lookup()`` will
# check the global scope first to see if the variable has been defined.
#
# This means that you can pre-declare a class and/or use an ENC and look up the
# variable whether it is declared this way or via Hiera or some other back-end.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
Puppet::Functions.create_function(:'simplib::lookup') do
  # @param param [String] The parameter that you wish to look up
  #
  # @param options [Hash] Hash of options for regular ``lookup()``
  #
  #   * This **must** follow the syntax rules for the
  #   Puppet ``lookup( [<NAME>], <OPTIONS HASH> )`` version of ``lookup()``
  #   * No other formats are supported!
  #
  # @see https://docs.puppet.com/puppet/latest/function.html#lookup - Lookup Function
  #
  # @return [Any] The value that is found in the system for the passed
  #   parameter.
  #
  # @example No defaults
  #   simplib::lookup('foo::bar::baz')
  #
  # @example With a default
  #   simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana' })
  #
  # @example With a typed default
  #   simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana', 'value_type' => String })
  #
  dispatch :lookup do
    param          'String', :param
    optional_param 'Any',    :options
  end

  def lookup(param, options = nil)
    global_param = closure_scope.find_global_scope.lookupvar(param)

    return global_param if global_param

    if options
      return call_function('lookup', param, options )
    else
      return call_function('lookup', param )
    end
  end
end
