# _Description_
#
# Return the default gw interface of the system.
#
Facter.add(:defaultgatewayiface) do
  setcode do
    confine :kernel => 'Linux'

    netstat = %x{/bin/netstat -rn}
    gw_iface = "unknown"
    if netstat =~ /^0\.0\.0\.0\s+(.*)/ then
      gw_iface = $1.split(/\s+/).last
    end

    gw_iface
  end
end
