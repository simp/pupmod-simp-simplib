# _Description_
#
#
# Return the current system runlevel
#
Facter.add("runlevel") do
    setcode do
        %x{"/sbin/runlevel"}.split.last
    end
end
