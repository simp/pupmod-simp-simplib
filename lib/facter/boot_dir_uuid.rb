# Return the UUID of the partition holding the /boot directory
Facter.add('boot_dir_uuid') do
  confine :kernel => 'Linux'

  setcode do
    df_cmd = Facter::Util::Resolution.which('df')
    blkid_cmd = Facter::Util::Resolution.which('blkid')

    partition = Facter::Core::Execution.exec("#{df_cmd} -P /boot").strip.split("\n").last.split(' ').first

    uuid = Facter::Core::Execution.exec("#{blkid_cmd} -s UUID -o value #{partition}").strip

    uuid = nil if (uuid.nil? || uuid.empty?)

    uuid
  end
end
