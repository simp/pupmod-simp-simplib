# _Description_
#
# Return a hash of connected USB devices
#
Facter.add(:lsusb) do
  confine :kernel => "Linux"
  retval = {}
  if Facter::Util::Resolution.which('lsusb')
    Facter::Util::Resolution.exec("lsusb 2>/dev/null").each_line do |line|
      line.match(/Bus (\d+) Device (\d+): ID ([0-9abcde:]{9}) .*/) do |match|

        bus = match[0]
        device = match[1]
        vendor = match[2].split(':')[0]
        product = match[2].split(':')[1]

        if not retval.has_key?(bus)
          retval[bus] = {}
        end

        if not retval[bus].has_key?(device)
          retval[bus][device] = {}
        end

        if not retval[bus][device].has_key?(vendor)
          retval[bus][device][vendor] = {}
        end

        retval[bus][device][vendor][product] = match[3].strip
      end
    end
  end

  setcode do
    retval
  end

end

