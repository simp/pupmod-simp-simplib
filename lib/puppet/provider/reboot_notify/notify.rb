Puppet::Type.type(:reboot_notify).provide(:notify) do
  desc "Management of the reboot notification metadata file."

  def initialize(*args)
    super(*args)

    @target = "#{Puppet[:vardir]}/reboot_notifications.json"
  end

  def exists?
    @records = {}

    begin
      @records = PSON.parse(File.read(@target))
    rescue
      return false
    end

    return File.exist?(@target)
  end

  def create
    File.open(@target,'w'){|fh| fh.puts(PSON.pretty_generate({}))}
  end

  def destroy
    File.unlink(@target)
  end

  def update
    @records ||= {}

    # Add your record
    @records[@resource[:name]] = {
      :reason  => @resource[:reason],
      :updated => Time.now.tv_sec
    }

    File.open(@target,'w'){|fh| fh.puts(PSON.pretty_generate(@records))}
  end

  def self.post_resource_eval
    # Have to repeat this here because everything in the provider is
    # now out of scope.
    target = "#{Puppet[:vardir]}/reboot_notifications.json"
    records = {}
    begin
      records = PSON.parse(File.read(target))
    rescue
      Puppet.error("Could not parse file: #{target}")
    end

    current_time = Time.now.tv_sec

    # Purge any records older than our uptime (we rebooted).
    records.delete_if{|k,v|
      (current_time - v["updated"]) > Facter.value(:uptime_seconds)
    }

    if not records.empty? then
      msg = ["System Reboot Required Because:"]

      records.each_pair do |k,v|
        # This is a fail safe for empty 'reasons'
        records[k]['reason'] = 'modified' if ( records[k]['reason'].nil? or records[k]['reason'].empty? )
        msg << ["  #{k} => #{v['reason']}"]
      end

      Puppet.notice(msg.join("\n"))
    end

    File.open(target,'w'){|fh| fh.puts(PSON.pretty_generate(records))}
  end
end
