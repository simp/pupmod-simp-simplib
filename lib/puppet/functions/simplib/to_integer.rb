# Converts the argument into an `Integer`.
# Only works if the passed argument responds to the `to_i()` Ruby method.
#
Puppet::Functions.create_function(:'simplib::to_integer') do

  # @param input The argument to convert into an `Integer`
  # @return [Integer] Converted input
  dispatch :to_integer do
    required_param 'Any', :input
  end

  def to_integer(input)
    return input if input.is_a?(Integer)

    if input.respond_to?(:to_i)
      return input.to_i
    else
      fail("simplib::to_integer(): Object type '#{input.class}' cannot be converted to an Integer")
    end
  end
end
