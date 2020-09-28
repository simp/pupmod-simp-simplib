# _Description_
#
# Return a structured NUMA fact with possible nodes, online nodes
# and a memory mapping layout
#
Facter.add('simplib__numa') do
  confine :kernel => 'Linux'
  confine { File.exist? '/sys/devices/system/node' }

  setcode do
    result = {}

    # read the 'possible' nodes file
    if File.exist?('/sys/devices/system/node/possible')
      result['possible'] = File.read('/sys/devices/system/node/possible').strip
    end

    # read the 'online' nodes file
    if File.exist?('/sys/devices/system/node/online')
      result['online'] = File.read('/sys/devices/system/node/online').strip
    end

    require 'pathname'
    Dir.glob('/sys/devices/system/node/node*').each do | file |
      meminfo_file = Pathname.new(File.join(file, 'meminfo'))
      next unless meminfo_file.exist?

      File.foreach(meminfo_file) do | text |
        if text =~ /\sMemTotal:\s+(\d+)/
          result[File.basename(file)] ||= {}
          result[File.basename(file)]['MemTotalBytes'] = ($1.to_i * 1024)
        end
      end
    end

    result
  end
end
