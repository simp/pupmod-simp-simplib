# _Description_
#
# Return a structured NUMA fact with possible nodes, offline nodes
# and a memory mapping layout
#
Facter.add("simplib__numa") do
  confine :kernel => 'Linux'
  confine { File.exist? '/sys/devices/system/node' }

  setcode do
    result = {}

    # read the 'possible' nodes file
    if File.exist?('/sys/devices/system/node/possible')
      result['possible'] = File.read('/sys/devices/system/node/possible').strip
    end

    # read the 'offline' nodes file
    if File.exist?('/sys/devices/system/node/offline')
      result['offline'] = File.read('/sys/devices/system/node/offline').strip
    end

    Dir.glob('/sys/devices/system/node/node*').each do | file |
      begin
        File.foreach(file + '/meminfo') do | text |
          if text =~ / MemTotal:/
            kb = text.delete("^0-9")
            bytes = kb.to_i * 1024
            result[File.basename(file)]['MemTotalBytes'] = bytes
          end
        end
      end

    result
  end

end
