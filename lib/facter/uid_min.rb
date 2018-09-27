# _Description_
#
# Return the minimum uid allowed
#
Facter.add('uid_min') do
  setcode do
    uid_min = ''
    if File.readable?('/etc/login.defs')
      uid_min = File.open('/etc/login.defs').grep(/UID_MIN/)
      unless uid_min.empty?
        uid_min = uid_min.first.to_s.chomp.split.last
      end
    end

    unless uid_min.empty?
      if ['RedHat','CentOS','OracleLinux','Scientific'].include?(Facter.value(:operatingsystem)) &&
         Facter.value(:operatingsystemmajrelease) < '7' then
          uid_min = '500'
      else
        uid_min = '1000'
      end
    end

    uid_min
  end
end
