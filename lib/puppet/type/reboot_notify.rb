module Puppet
  newtype(:reboot_notify) do
    @doc = "Notifies users when a system reboot is required.

      This type creates a file at $target the contents of which
      provide a summary of the reasons why the system requires a
      reboot.

      NOTE: This type will *only* register entries on refresh. Any
      other use of the type will not report the necessary reboot.

      A reboot notification will be printed at each puppet run until
      the system is successfully rebooted."

    ensurable do
      defaultto(:present)

      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end
    end

    newparam(:name) do
      desc "The item that is being modified that requires a reboot"
    end

    newparam(:reason) do
      desc "An optional reason for rebooting."
      defaultto('modified')
    end

    # We only update on refresh
    def refresh
      provider.update if self[:ensure] == :present
    end
  end
end
