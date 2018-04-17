Puppet::Type.type(:reboot_notify).provide(:notify) do
  desc "Management of the reboot notification metadata file."

  def initialize(*args)
    super(*args)

    @target = "#{Puppet[:vardir]}/reboot_notifications.json"
  end

  def exists?
    @records = {}

    begin
      @records = JSON.parse(File.read(@target))
    rescue
      return false
    end

    return File.exist?(@target)
  end

  def create
    begin
      File.open(@target,'w'){|fh| fh.puts(JSON.pretty_generate({}))}
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not create '#{@target}': #{e}")
    end
  end

  def destroy
    File.unlink(@target) if File.exist?(@target)
  end

  def update
    @records ||= {}

    # Add your record
    @records[@resource[:name]] = {
      :reason  => @resource[:reason],
      :updated => Time.now.tv_sec
    }

    begin
      File.open(@target,'w') { |fh| fh.puts(JSON.pretty_generate(@records)) }
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not update '#{@target}': #{e}")
    end
  end

  def self.post_resource_eval
    # Have to repeat this here because everything in the provider is
    # now out of scope.
    target = "#{Puppet[:vardir]}/reboot_notifications.json"
    records = {}
    content = ''

    begin
      content = File.read(target)
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not read file '#{target}': #{e}")
    end

    begin
      records = JSON.parse(content)
    rescue => e
      raise(Puppet::Error, "reboot_notify: Invalid JSON in '#{target}': #{e}")
    end

    current_time = Time.now.tv_sec

    # Purge any records older than our uptime (we rebooted).
    records.delete_if{|k,v|
      (current_time - v["updated"]) > Facter.value(:uptime_seconds)
    }

    unless records.empty?
      msg = ["System Reboot Required Because:"]

      records.each_pair do |k,v|
        # This is a fail safe for empty 'reasons'
        records[k]['reason'] = 'modified' if ( records[k]['reason'].nil? || records[k]['reason'].empty? )
        msg << ["  #{k} => #{v['reason']}"]
      end

      Puppet.notice(msg.join("\n"))
    end

    begin
      File.open(target,'w'){|fh| fh.puts(JSON.pretty_generate(records))}
    rescue
      raise(Puppet::Error, "reboot_notify: Could not update '#{@target}': #{e}")
    end
  end
end
