# _Description_
#
# Return true if system booted via uEFI Secure Boot
#
if Facter.value(:kernel).downcase == "linux" then
  Facter.add("secure_boot_enabled") do
    setcode do
      if File.exist?('/sys/firmware/efi')
        Dir.glob('/sys/firmware/efi/efivars/SecureBoot-*').each do | file |
          File.open(file, 'r') do | hexcode |
            hexcode.read(4)
            code = hexcode.read(16).unpack('H*').first.to_i
            if code == 1
              true
            else
              false
            end
          end
        end
      else
        false
      end
    end
  end
end
