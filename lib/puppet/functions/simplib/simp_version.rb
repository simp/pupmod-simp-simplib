# Return the version of SIMP that this server is running or "unknown\n"
Puppet::Functions.create_function(:'simplib::simp_version') do

  # @param strip_whitespace Whether to strip whitespace from the
  #   version string.  Without stripping, the string may end with
  #   a "\n"
  # @return [String] Version string if the version can be detected;
  #   "unknown\n" otherwise
  dispatch :simp_version do
    optional_param 'Boolean', :strip_whitespace
  end

  def simp_version(strip_whitespace = false)
    retval = "unknown\n"

    begin
      # TODO Figure out under what circumstances the version string is prefaced
      # with 'simp-'. This is not true for SIMP 6.x
      version = File.read('/etc/simp/simp.version').gsub('simp-','')
      retval = version unless version.strip.empty?
    rescue
      rpm_query = %q{PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null}
      version = `#{rpm_query}`
      retval = version if $?.success?
    end

    retval.strip! if strip_whitespace
    retval
  end
end
