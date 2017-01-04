module Puppet::Parser::Functions
  newfunction(:validate_port, :doc => <<-EOS) do |arguments|
      Validates whether or not the passed argument is a valid port (i.e. between 1 - 65535).

      The following values will pass:
        $port = '10541'
        $ports = ['5555', '7777', '1', '65535']
        validate_port($port)
        validate_port($ports)
        validate_port('11', '22')

      The following values will not pass:
        validate_port('0')
        validate_port('65536')
        validate_port(['1', '1000', '100000'])
    EOS

    unless arguments.length > 0 then
      raise(Puppet::ParseError, "validate_port(): Wrong number of arguments: #{arguments.length}; must be > 0")
    end

    arguments.each do |arg|
      arg = Array(arg)
      arg.each do |port|
        if not port.to_i.between?(1,65535) then
          raise Puppet::ParseError, ("'#{port}' is not a valid port.")
        end
      end
    end
  end
end

#
