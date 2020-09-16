# _Description_
#
# Return true if system booted via uEFI Secure Boot
#
Facter.add("simplib__secure_boot_enabled") do
  confine :kernel => 'Linux'

  setcode do
    retval = false

    Dir.glob('/sys/firmware/efi/efivars/SecureBoot-*').each do | file |
      File.open(file, 'r') do | hexcode |
        # skip leading status codes
        hexcode.read(4)
        code = hexcode.read()
        # If we didn't get any data, unpacking will fail
        retval = (1 == code.unpack('H*').first.to_i) if code
      end
    end
    if retval
      Dir.glob('/sys/firmware/efi/efivars/SetupMode-*').each do | file |
        File.open(file, 'r') do | hexcode |
          # skip leading status codes
          hexcode.read(4)
          code = hexcode.read()
          # If we didn't get any data, unpacking will fail
          retval = (0 == code.unpack('H*').first.to_i) if code
        end
      end
    end

    retval
  end
end
