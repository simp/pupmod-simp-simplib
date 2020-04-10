require 'spec_helper_acceptance'

test_name 'simplib__sshd_config fact'

describe 'simplib__sshd_config fact' do

  hosts.each do |host|
    it 'The SSH version should be gathered' do
      fact_info = pfact_on(host, 'simplib__sshd_config')

      expect(fact_info['version']).to match(/^\d+\.\d+/)
      expect(fact_info['version']).to match(/[^\s]/)

      expect(fact_info['full_version']).to match(/^OpenSSH_\d+\.\d+/)
      expect(fact_info['full_version']).to match(/\s/)

      expect(fact_info['AuthorizedKeysFile']).to match(/.+/)
    end
  end
end
