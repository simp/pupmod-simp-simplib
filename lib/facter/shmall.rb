# = Fact - Shmall =
#
# Return the value of shmall from sysctl.
#
Facter.add("shmall") do
  confine :kernel => 'Linux'
  setcode do
    %x{/sbin/sysctl -n kernel.shmall}.strip
  end
end

