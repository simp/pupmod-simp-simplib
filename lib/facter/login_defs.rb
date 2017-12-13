# Returns the contents of /etc/login.defs as a hash with downcased keys
#
Facter.add('login_defs') do
  confine do
    File.exist?('/etc/login.defs') && File.readable?('/etc/login.defs')
  end

  setcode do
    def read_login_defs
      File.read('/etc/login.defs')
    end

    if ['RedHat','CentOS'].include?(Facter.value(:operatingsystem)) &&
       Facter.value(:operatingsystemmajrelease) < '7'
        id_min = 500
    else
      id_min = 1000
    end

    attribute_hash = read_login_defs.lines.
      delete_if{|x| x =~ /^\s*(#|$)/}.
      map{|x| x = x.split(/\s+/); x[0].downcase!; x}.
      to_h

    attribute_hash.each do |k, v|
      # We have a few special cases to take care of

      # Leave the umask as a string
      next if k == 'umask'

      # Change yes/no to true/false
      if v == 'yes'
        attribute_hash[k] = true
      elsif v == 'no'
        attribute_hash[k] = false
      elsif v =~ /^\d+$/
        attribute_hash[k] = v.to_i
      end
    end

    ['uid_min', 'gid_min'].each do |id_attr|
      unless attribute_hash[id_attr]
        attribute_hash[id_attr] = id_min
      end
    end

    attribute_hash
  end
end
