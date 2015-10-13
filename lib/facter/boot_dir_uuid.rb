# Return the UUID of the partition holding the /boot directory
Facter.add('boot_dir_uuid') do
  setcode do
    df_cmd = Facter::Util::Resolution.which('df')
    blkid_cmd = Facter::Util::Resolution.which('blkid')

    boot_uuid = Facter::Core::Execution.exec("#{df_cmd} -T /boot").strip.split("\n").last.split(' ').first

    Facter::Core::Execution.exec("#{blkid_cmd} -s UUID -o value #{boot_uuid}")
  end
end
