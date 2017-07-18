# _Description_
#
# Return true if IPv6 is enabled and false if not.
# Known to work on 2.4.6 kernels.
#
Facter.add("ipv6_enabled") do
  confine :kernel => 'Linux'
  setcode do
    retval = false
    ipv6_enabled = Facter::Core::Execution.exec('/sbin/sysctl -n -e net.ipv6.conf.all.disable_ipv6 2>/dev/null')

    # we have observed this exec non-deterministically populate $? with
    # nil, although the exec succeeds.  This will happen with %x, ``, or
    # Facter.*.exec.
    #
    # For now we test around the issue by checking the output if $? is nil:
    if ($?.nil? && ipv6_enabled) ||
       (!$?.nil? && $?.exitstatus.zero? && ipv6_enabled.chomp == "0")
    then
      retval = true
    end

    retval
  end
end
