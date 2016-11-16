# This facter fact returns a hash of all Puppet settings for the node running
# puppet or puppet agent. The intent is to enable Puppet modules to
# automatically be able to use the various aspects of the puppet system
# regardless of the node's platform.
#
# Each entry is under a hash entry of its associated section

Facter.add(:puppet_settings) do
  setcode do
    retval = {}

    if Object.const_defined?('Puppet')
      puppet_settings = Hash[Puppet.settings.map{|k,v| [k,v]}]

      puppet_settings.each_pair do |name, obj|
        next if obj.deprecated?

        # For older versions of Facter, no hash keys/values can be symbols
        retval[obj.section.to_s] ||= {}
        retval[obj.section.to_s][name.to_s] = obj.value.to_s
      end
    end

    retval
  end
end
