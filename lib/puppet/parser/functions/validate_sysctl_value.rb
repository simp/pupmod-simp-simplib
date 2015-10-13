module Puppet::Parser::Functions

  newfunction(:validate_sysctl_value, :doc => <<-'ENDHEREDOC', :arity => 2) do |args|
    Validate that the passed value is correct for the passed sysctl key.

    If a key is not know, simply returns that the value is valid.

    Example:
      validate_sysctl_value('kernel.core_pattern','some_random_pattern %p')
    ENDHEREDOC

    # BEGIN: recognized value methods
    def self.kernel__core_pattern(val)
      method = 'kernel.core_pattern'

      if val.length > 128 then
        raise(Puppet::Error,"Values for #{method} must be less than 129 characters")
      end

      if val =~ /\|\s*(.*)/ then
        begin
          function_validate_absolute_path([$1])
        rescue(Puppet::Error)
          raise(Puppet::Error,"Piped commands for #{method} must have an absolute path")
        end
      end
    end
    # END: recognized value methods

    # Need the 'validate_absolute_path' function from stdlib.
    Puppet::Parser::Functions.autoloader.loadall

    key = args[0].to_s.gsub('.','__')
    val = args[1].to_s

    self.send(key,val) if self.respond_to?(key)
  end
end
