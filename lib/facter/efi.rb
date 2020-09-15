# _Description_
#
# Return true if system booted via EFI
#
if Facter.value(:kernel).downcase == "linux" then
  Facter.add("efi_enabled") do
    setcode do
      File.exist?('/sys/firmware/efi')
    end
  end
end
