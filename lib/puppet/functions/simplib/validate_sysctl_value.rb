# Validate that the passed value is correct for the passed `sysctl` key.
#
# * If a key is not known, assumes the value is valid.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_sysctl_value') do

  # @param key sysctl setting whose value is to be validated
  # @param value Value to be validated
  # @return [Nil]
  # @raise RuntimeError upon validation failure
  # @example Passing validation
  #   validate_sysctl_value('kernel.core_pattern','/var/core/%u_%g_%p_%t_%h_%e.core')

  dispatch :validate_sysctl_value do
    required_param 'String',:key
    required_param 'String',:value
  end

  def validate_sysctl_value(key, value)

    key_method_name = key.to_s.gsub('.','__')

    self.send(key_method_name,value) if self.respond_to?(key_method_name)
  end

  # Below are the recognized validation methods

  def kernel__core_pattern(value)
    method = 'kernel.core_pattern'

    if value.length > 128
      fail("simplib::validate_sysctl_value(): Values for #{method} must be less than 129 characters")
    end

    if value =~ /\|\s*(\S*)/
      require 'puppet/util'
      unless  Puppet::Util.absolute_path?($1, :posix)
        fail("simplib::validate_sysctl_value(): Piped commands for #{method} must have an absolute path")
      end
    end
  end
end
