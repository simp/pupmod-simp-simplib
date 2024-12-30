# _Description_
#
# Return the minimum uid allowed
#
Facter.add('uid_min') do
  confine { File.exist?('/etc/login.defs') }

  setcode do
    uid_min = File.open('/etc/login.defs').grep(%r{UID_MIN})

    # Grep returns an Array
    uid_min = '' if uid_min.empty?

    unless uid_min.empty?
      uid_min = uid_min.first.to_s.chomp.split.last
    end

    uid_min = '1000' unless uid_min.empty?

    uid_min
  end
end
