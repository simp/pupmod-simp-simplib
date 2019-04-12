# _Description_
#
# Return values from the /etc/ssh/sshd_conf file
#
Facter.add('simplib__sshd_config') do
  confine { File.exist?('/etc/ssh/sshd_config') && File.readable?('/etc/ssh/sshd_config')}

  setcode do

    # Currently only checking for AuthorizedKeysFile but leaving flexible for future additions
    # Read contents of /etc/ssh/sshd_config 
    sshd_config = File.read('/etc/ssh/sshd_config')

    #Find desired parameter
    match_result = sshd_config.match(/^AuthorizedKeysFile\s+(\S+)/)

    # Set default location if not found otherwise use matchresult
    authorizedkeysfile =  match_result.nil? ? '.ssh/authorized_keys':match_result[1]

    attribute_hash = { 'authorizedkeysfile' => authorizedkeysfile }

    attribute_hash
  end
end
