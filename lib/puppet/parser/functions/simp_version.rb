module Puppet::Parser::Functions
  newfunction(:simp_version, :type => :rvalue, :doc => <<-EOM) do |args|
    Return the version of SIMP that this server is running

    @return [String]
    EOM

    function_simplib_deprecation(['simp_version', 'simp_version is deprecated, please use simplib::simp_version'])

    retval = "unknown\n"

    if File.readable?('/etc/simp/simp.version')
    # TODO Figure out under what circumstances the version string is prefaced
    # with 'simp-'. This is not true for SIMP 6.x
      version = File.read('/etc/simp/simp.version').gsub('simp-','')
      retval = version unless version.strip.empty?
    else
      rpm_query = %q{PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null}
      begin
        version = Puppet::Util::Execution.execute(rpm_query, :failonfail => true)
      rescue Puppet::ExecutionFailure
        version = nil
      end
      retval = version if version
    end

    retval
  end
end
