Puppet::Type.type(:runlevel).provide(:systemd) do
  desc <<-EOM
    Set the system runlevel using systemd
  EOM

  commands :systemctl => '/usr/bin/systemctl'
  defaultfor :kernel => 'Linux'

  def level
    Facter.value(:runlevel)
  end

  def level=(should)
    require 'timeout'

    begin
      Timeout::timeout(@resource[:transition_timeout]) do
        execute([command(:systemctl),'isolate',init2systemd(@resource[:name])])
      end
    rescue Timeout::Error
      raise(Puppet::Error, "Could not transition to runlevel #{@resource[:name]} within #{@resource[:transition_timeout]} seconds")
    end
  end

  def persist
    if execute([command(:systemctl),'get-default']).strip == init2systemd(@resource[:name])
      return :true
    else
      return :false
    end
  end

  def persist=(should)
    execute([command(:systemctl),'set-default',init2systemd(@resource[:name])])
  end

  private

  def init2systemd(input)
    runlevel = input

    if input == '5'
      runlevel = 'graphical.target'
    elsif input == '1'
      runlevel = 'rescue.target'
    elsif input =~ /^\d+$/
      runlevel = 'multi-user.target'
    elsif input !~ /.*\.target/
      runlevel = "#{input}.target"
    end

    return runlevel
  end
end
