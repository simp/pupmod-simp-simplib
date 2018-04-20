Puppet::Type.type(:reboot_notify).provide(:notify) do
  desc 'Management of the reboot notification metadata file.'

  def self.default_control_metadata
    return {
      'reboot_control_metadata' => {
        'log_level' => 'notice'
      }
    }
  end

  def initialize(*args)
    super(*args)

    @target = File.join(Puppet[:vardir], 'reboot_notifications.json')

    @records = self.class.default_control_metadata
  end

  def exists?
    begin
      require 'deep_merge'

      @records = self.class.default_control_metadata.deep_merge(
        JSON.parse(File.read(@target))
      )
    rescue => e
      Puppet.debug("reboot_notify: #exists? => #{e}")
      return false
    end

    return File.exist?(@target)
  end

  def create
    begin
      File.open(@target,'w'){|fh| fh.puts(JSON.pretty_generate(@records))}
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not create '#{@target}': #{e}")
    end
  end

  def destroy
    File.unlink(@target) if File.exist?(@target)
  end

  def update
    if @resource[:log_level]
      @records['reboot_control_metadata']['log_level'] = @resource[:log_level]
    end

    unless @resource[:control_only]
      # Add your record
      @records[@resource[:name]] = {
        :reason  => @resource[:reason],
        :updated => Time.now.tv_sec
      }
    end

    begin
      File.open(@target,'w') { |fh| fh.puts(JSON.pretty_generate(@records)) }
    rescue => e
      raise(Puppet::Error, "reboot_notify: Could not update '#{@target}': #{e}")
    end
  end

  def self.post_resource_eval
    # Have to repeat this here because everything in the provider is
    # now out of scope.
    target = File.join(Puppet[:vardir], 'reboot_notifications.json')
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

    if records['reboot_control_metadata']
      reboot_control_metadata = records.delete('reboot_control_metadata')
    else
      reboot_control_metadata = self.default_control_metadata['reboot_control_metadata']
    end

    # Purge any records older than our uptime (we rebooted).
    records.delete_if{|k,v|
      next unless v['updated']

      (current_time - v['updated']) > Facter.value(:uptime_seconds)
    }

    unless records.empty?
      msg = ['System Reboot Required Because:']

      records.each_pair do |k,v|
        next unless v['updated']

        # This is a fail safe for empty 'reasons'
        records[k]['reason'] = 'modified' if ( records[k]['reason'].nil? || records[k]['reason'].empty? )
        msg << ["  #{k} => #{v['reason']}"]
      end

      log_level = reboot_control_metadata['log_level'].to_sym

      begin
        Puppet.send(log_level, msg.join("\n"))
      rescue NoMethodError
        Puppet.warning("Invalid log_level: '#{log_level}'")
        Puppet.notice(msg.join("\n"))
      end
    end

    begin
      File.open(target,'w'){|fh| fh.puts(JSON.pretty_generate(records))}
    rescue
      raise(Puppet::Error, "reboot_notify: Could not update '#{@target}': #{e}")
    end
  end
end
