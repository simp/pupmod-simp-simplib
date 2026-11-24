# _Description_
#
# Return the current system runlevel.
#
# Legacy distributions ship `/sbin/runlevel`, which reports the runlevel the
# system is currently in. On systemd-only distributions (e.g. Fedora 43 and
# later) that binary no longer exists, so the equivalent is derived from the
# active targets instead. `systemctl get-default` is deliberately not used
# here: it reports the target the system will boot into, which is not
# necessarily the one it is running in.
#
Facter.add('runlevel') do
  confine kernel: 'Linux'
  setcode do
    if (runlevel_bin = Facter::Core::Execution.which('runlevel'))
      (Facter::Core::Execution.execute(runlevel_bin, on_fail: nil) || '').split.last
    elsif Facter::Core::Execution.which('systemctl')
      active_targets = (
        Facter::Core::Execution.execute(
          'systemctl list-units --type=target --state=active --plain --no-legend --no-pager',
          on_fail: nil,
        ) || ''
      ).lines.map { |line| line.split.first }.compact

      # Highest runlevel wins, mirroring runlevel(8): a system booted into
      # graphical.target also has multi-user.target active, but reports 5.
      target_to_runlevel = {
        'reboot.target'     => '6',
        'graphical.target'  => '5',
        'multi-user.target' => '3',
        'rescue.target'     => '1',
        'poweroff.target'   => '0',
      }

      matched = target_to_runlevel.keys.find { |target| active_targets.include?(target) }

      target_to_runlevel[matched] if matched
    end
  end
end
