# _Description_
#
# Return the default gateway of the system
#
Facter.add(:defaultgateway) do
    setcode do
        netstat = %x{/bin/netstat -rn}
        gw = "unknown"
        if netstat =~ /^0\.0\.0\.0\s+(.*)/ then
            gw = $1.split(/\s+/).first
        end

        gw
    end
end
