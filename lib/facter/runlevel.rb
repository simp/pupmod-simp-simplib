# _Description_
#
#
# Return the current system runlevel
#
Facter.add('runlevel') do
  confine kernel: 'Linux'
  setcode do
    runlevel = nil

    if (runlevel_path = Facter::Core::Execution.which('runlevel'))
      result = Facter::Core::Execution.exec(runlevel_path)
      runlevel = result.split.last if result
    elsif Facter::Core::Execution.which('systemctl')
      # Map systemd targets to traditional SysV runlevels
      target_to_runlevel = {
        'poweroff.target'   => '0',
        'rescue.target'     => '1',
        'multi-user.target' => '3',
        'graphical.target'  => '5',
        'reboot.target'     => '6',
      }
      result = Facter::Core::Execution.exec('systemctl get-default')
      runlevel = target_to_runlevel[result&.strip]
    end

    runlevel
  end
end
