Puppet::Type.type(:runlevel).provide(:telinit) do
  desc <<-EOM
    Set the system runlevel using telinit
  EOM

  commands :telinit => '/sbin/telinit'

  def level
    Facter.value(:runlevel)
  end

  def level=(should)
    execute([command(:telinit),@resource[:name]])
  end

  def persist
    retval = :false

    if @resource[:persist] == :true then
      inittab = File.open('/etc/inittab', 'r')
      inittab.each_line do |line|
        if line =~ /^\s*id/ then
          # We have the initdefault line
          current_value = line.split(':').at(1)
          if current_value.eql?(@resource[:name]) then
            retval = :true
          end
        end
      end
      inittab.close
    end

    retval
  end

  def persist=(should)
    # Essentially do the same as the read, but save contents to new file
    newfile = String.new
    inittab = File.open('/etc/inittab', 'r')
    inittab.each_line do |line|
      if line =~ /^\s*id/ then
        # We've found the default line, so rewrite
        newfile << "id:#{@resource[:name]}:initdefault:nil\n"
      else
        # Just add this line as is
        newfile << line
      end
    end
    inittab.close

    inittab = File.open('/etc/inittab', 'w')
    inittab.write(newfile)
    inittab.close
  end
end
