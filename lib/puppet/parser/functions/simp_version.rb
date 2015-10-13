module Puppet::Parser::Functions
  newfunction(
    :simp_version,
    :type => :rvalue,
    :doc => "Return the version of SIMP that this server is running."
  ) do |args|

    retval = "unknown\n"

    begin
      retval = File.read('/etc/simp/simp.version').gsub('simp-','')
    rescue
      tmpval = %x{/bin/rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp}
      $?.success? and retval = tmpval
    end

    retval
  end
end
