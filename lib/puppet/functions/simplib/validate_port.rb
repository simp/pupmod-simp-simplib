# Validates whether or not the passed argument is a valid port
# (i.e. between `1` - `65535`).
Puppet::Functions.create_function(:'simplib::validate_port') do
  local_types do
    type 'StringOrInteger = Variant[String[1],Integer]'
    type 'StringOrIntegerArray = Array[StringOrInteger,1]'
  end

  # @param port_args Arguments each of which contain either an
  #   individual port or an array of ports.
  # @return [Nil]
  #
  # @example Passing
  #   $port = '10541'
  #   $ports = [5555, '7777', '1', '65535']
  #   simplib::validate_port($port)
  #   simplib::validate_port($ports)
  #   simplib::validate_port('11', 22)
  #   simplib::validate_port('11', $ports)
  #
  # @example Failing
  #   simplib::validate_port('0')
  #   simplib::validate_port(65536)
  #   simplib::validate_port('1', '1000', '100000')
  #   simplib::validate_port(['1', '1000', '100000'])
  #   simplib::validate_port('1', ['1000', '100000'])
  dispatch :validate_ports do
    required_repeated_param 'Variant[String[1],Integer,StringOrIntegerArray]', :port_args
  end

  def validate_ports(*port_args)
    ports = Array(port_args).flatten
    ports.each do |port|
      if not port.to_i.between?(1,65535) then
        fail("simplib::validate_ports: '#{port}' is not a valid port.")
      end
    end
  end
end
