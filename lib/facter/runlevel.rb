# _Description_
#
#
# Return the current system runlevel
#
Facter.add("runlevel") do
  confine :kernel => 'Linux'
  setcode do
    %x{"/sbin/runlevel"}.split.last
  end
end
