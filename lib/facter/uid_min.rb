Facter.add('uid_min') do
  setcode do
    if File.readable?('/etc/login.defs') then
      uid_min = File.open('/etc/login.defs').grep(/UID_MIN/)
      if not uid_min.empty? then
        uid_min = uid_min.first.to_s.chomp.split.last
      else
        uid_min = ''
      end
    end

    if not uid_min or uid_min.empty? then
      if ['RedHat','CentOS'].include?(Facter.value(:operatingsystem)) and
         Facter.value(:operatingsystemmajrelease) < '7' then
          uid_min = '500'
      else
        uid_min = '1000'
      end
    end

    uid_min
  end
end
