module Puppet::Parser::Functions
  newfunction(:simp_version, :type => :rvalue, :doc => <<-EOM) do |args|
    Return the version of SIMP that this server is running

    @return [String]
    EOM

    retval = "unknown\n"

    begin
      retval = File.read('/etc/simp/simp.version').gsub('simp-','')
    rescue
      tmpval = %x{PATH='/usr/local/bin:/usr/bin:/bin'; rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp}
      $?.success? and retval = tmpval
    end

    retval
  end
end
