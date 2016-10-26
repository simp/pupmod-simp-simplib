# This facter fact returns a hash of all Puppet settings for the node running
# puppet or puppet agent. The intent is to enable Puppet modules to
# automatically be able to use the various aspects of the puppet system
# regardless of the node's platform.
#
# Each entry is under a hash entry of its associated section

begin
  require 'facter/util/puppet_settings'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'puppet_settings.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

Facter.add(:puppet_settings) do
  setcode do
    retval = {}
    # This will be nil if Puppet is not available.
    Facter::Util::PuppetSettings.with_puppet do
      Puppet.settings.each do |setting|
        key, params = setting

        # Apparently, accessing these is deprecated
        deprecated_access = [
          :req_bits,
          :ignorecache,
          :configtimeout
        ]
        next if deprecated_access.include?(key)

        # This is nonsensical
        next if (key == :name) && (params.section == :main)

        next if (!Puppet[key] || (Puppet[key].respond_to?(:empty?) && Puppet[key].empty?))

        # For older versions of Facter, no hash keys/values can be symbols
        retval[params.section.to_s] ||= {}
        retval[params.section.to_s][params.name.to_s] = Puppet[key].to_s
      end
    end

    retval
  end
end
