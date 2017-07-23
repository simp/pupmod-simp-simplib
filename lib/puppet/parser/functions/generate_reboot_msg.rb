module Puppet::Parser::Functions
  newfunction(:generate_reboot_msg, :type => :rvalue, :doc => <<-ENDHEREDOC) do |input_hash|
    Generate a reboot message from a passed `Hash`.

    Requires a `Hash` of the following form:

    ``ruby
    {
      'id'  => 'reason',
      'id2' => 'reason2',
      ...
    }
    ``

    Will return a message such as:

    ``
    A system reboot is required due to:
      id => reason
      id2 => reason2
    ``

    @return [String]
    ENDHEREDOC

    input_hash = input_hash.shift

    raise(Puppet::ParseError,"Error: input to generate_reboot() must be a Hash, got '#{input_hash.class}'") unless input_hash.is_a?(Hash)
    raise(Puppet::ParseError,"Error: input to generate_reboot() must not be empty") if input_hash.empty?

    msg = ['System Reboot Required Because:']
    input_hash.each_pair do |k,v|
      if (not v or v.empty?) then
        msg << "  #{k}"
      else
        msg << "  #{k} => #{v}"
      end
    end

    msg.join("\n")
  end
end
