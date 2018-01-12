# _Description_
#
# Return a hash of prelink information:
# * enabled: Whether prelink is enabled.
#   Prelink is considered to be be disabled if /etc/sysconfig/prelink
#   does not exist, the PRELINKING variable in /etc/sysconfig/prelink
#   is not set to 'yes', or the PRELINKING variable is missing from
#   /etc/sysconfig/prelink.  This logic reflects how the PRELINKING 
#   variable is used in /etc/cron.hourly/prelink.
#
Facter.add(:prelink) do
  confine :kernel => 'Linux'

  confine { Facter::Core::Execution.which('prelink') }

  setcode do
    prelink_enabled = false
    if File.exist?('/etc/sysconfig/prelink')
      config = IO.readlines('/etc/sysconfig/prelink').delete_if do |line|
        !line.match(/^\s*PRELINKING=/)
      end
      unless config.empty?
        value = config.last.split('=')[1]
        if  value and value.strip == 'yes'
          prelink_enabled = true
        end
      end
    end

    { 'enabled' => prelink_enabled }
  end
end
