# _Description_
#
# return the content of lspci as a hash
Facter.add(:lspci) do
  confine :kernel => "Linux"
  retval = {}
  if Facter::Util::Resolution.which('lspci')
    slot = ''
    type = ''
    vendor = ''
    Facter::Util::Resolution.exec("lspci -vv -mm -k -b -D 2>/dev/null").each_line do |line|
      # only parse lines with text
      if line =~ /.+/
        txt = line.split(/:\t/)
        if txt[0] == 'Slot'
          slot = txt[1].strip
          type = ''
          vendor = ''
          next
        elsif txt[0] == 'Class'
          type = txt[1].strip
          next
        elsif txt[0] == 'Vendor'
          vendor = txt[1].strip
          next
        end

        if type != '' and slot != '' and vendor != ''
          if not retval.has_key?(type)
            retval[type] = {}
          end

          if not retval[type].has_key?(vendor)
            retval[type][vendor] = {}
          end

          if not retval[type][vendor].has_key?(slot)
            retval[type][vendor][slot] = {}
          end

          retval[type][vendor][slot][txt[0]] = txt[1].strip
        end
      else
        slot = ''
        type = ''
        vendor = ''
      end
    end
  end

  setcode do
    retval
  end

end
