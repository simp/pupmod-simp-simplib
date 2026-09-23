# @summary Return the status of auditding on the system
#
# The default entries of `enabled`, `enforcing`, and `kernel_enforcing` will always be returned.
#
# All other values will be pulled directly from `auditctl -s` and Integers will
# be converted to Integers. All other values will remain strings.
#
# @example Default Values
#
#   {
#     'enforcing',        => false # The state of `auditd` on the system
#     'kernel_enforcing', => false # The state of the kernel flag
#     'enabled'           => false # The `enabled` status from auditctl
#   }
#
# When the `simp/auditd` module is installed, its `auditd_state` fact already
# holds everything this fact reports, and this fact is built from it rather
# than running `auditctl` and `ps` a second time. Without it, this fact
# gathers the data itself. The result is the same either way.
#
# `enabled` is `true` only when the kernel reports `1`. An immutable rule set
# (`2`) reads as `false` here, as it always has; use `auditd_state` to tell
# the two apart.
#
Facter.add('simplib__auditd') do
  confine kernel: 'Linux'

  @auditctl = Facter::Core::Execution.which('auditctl')
  @ps = Facter::Core::Execution.which('ps')

  confine { !@auditctl.nil? }
  confine { !@ps.nil? }

  setcode do
    status = {
      'enforcing' => false,
      'kernel_enforcing' => false,
      'enabled' => 0,
    }

    auditd_state = Facter.value('auditd_state')

    if auditd_state
      # Everything auditd_state read from auditctl. The keys it derives are
      # left out: this fact derives its own below, with its own meaning of
      # `enabled`.
      status = status.merge(auditd_state.reject { |k, _v| ['immutable', 'kernel_enforcing', 'enforcing'].include?(k) })
    else
      audit_version = Facter::Core::Execution.execute("#{@auditctl} -v", on_fail: nil).split(%r{\s+}).last

      status['version'] = audit_version if audit_version && !audit_version.empty?

      auditctl_status = {}

      Facter::Core::Execution.execute("#{@auditctl} -s", on_fail: nil).lines.each do |l|
        l.strip!

        next if l.empty?

        k, v = l.split(%r{\s+}, 2)

        begin
          v = Integer(v)
        rescue
          nil
        end

        auditctl_status[k] = v
      end

      status = status.merge(auditctl_status)
    end

    status['enabled'] = (status['enabled'] == 1) ? true : false

    if status['enabled']
      status['kernel_enforcing'] = true

      status['enforcing'] = if auditd_state
                              # The same process check, already made.
                              auditd_state['enforcing'] == true
                            else
                              procs = Facter::Core::Execution.execute("#{@ps} -e", on_fail: nil).lines
                              procs.any? { |x| x =~ %r{\sauditd\Z} }
                            end
    else
      cmdline = Facter.value('cmdline') || {}
      status['kernel_enforcing'] = (cmdline['audit'].to_s == '1')
    end

    status
  end
end
