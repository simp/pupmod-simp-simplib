# @summary Return the status of auditding on the system
#
Facter.add('simplib__auditd') do
  confine :kernel => 'Linux'

  @auditctl = Facter::Util::Resolution.which('auditctl')

  confine { !@auditctl.nil? }

  setcode do
    status = {
      'enabled' => 0,
      'kernel_enforcing' => false
    }

    audit_version = Facter::Core::Execution.exec("#{@auditctl} -v").split(/\s+/).last

    status['version'] = audit_version if (audit_version && !audit_version.empty?)

    auditctl_status = {}

    Facter::Core::Execution.exec("#{@auditctl} -s").lines.each do |l|
      l.strip!

      next if l.empty?

      k,v = l.split(/\s+/, 2)

      begin
        v = Integer(v)
      rescue
        nil
      end

      auditctl_status[k] = v
    end

    status = status.merge(auditctl_status)
    status['enabled'] = status['enabled'] == 1 ? true : false

    if status['enabled']
      status['kernel_enforcing'] = true
    else
      cmdline = Facter.value('cmdline') || {}
      status['kernel_enforcing'] = ("#{cmdline['audit']}" == '1')
    end

    status
  end
end
