# Returns the contents of /proc/cmdline as a hash
Facter.add('cmdline') do
  confine { Gem::Version.new(Facter.version) >= Gem::Version.new('2') }
  confine { File.exist?('/proc/cmdline') }

  setcode do
    retval = {}
    begin
      File.read('/proc/cmdline').chomp.split.each{|x| i,j = x.split('='); retval[i] = j}
    rescue => details
      Facter.warn("Could not gather data from /proc/cmdline: #{details.message}")
    end
    retval
  end
end
