# Set a fact to return the version of slapd that is installed
#
Facter.add("slapd_version") do
  if ['RedHat','CentOS'].include?(Facter.value(:operatingsystem))
    if Facter.value(:operatingsystemmajrelease) < '7'
      $slapd_bin = '/usr/sbin/slapd'
    else
      $slapd_bin = '/sbin/slapd'
    end
    confine { File.exist?($slapd_bin) && File.executable?($slapd_bin) }
    setcode do
      out = `/sbin/slapd -VV 2>&1`
      version = out.match(/slapd (\d+\.\d+\.\d+)/)
      $1
    end
  end
end
