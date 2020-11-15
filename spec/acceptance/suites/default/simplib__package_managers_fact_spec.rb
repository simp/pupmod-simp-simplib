require 'spec_helper_acceptance'

test_name 'simplib__package_managers fact'

describe 'simplib__package_managers fact' do

  hosts.each do |host|
    it 'The package manager version(s) should be gathered' do
      fact_info = pfact_on(host, 'simplib__package_managers')

      expect(fact_info).to be_a(Hash)
      expect(fact_info['yum']).to match(/^\d+\.\d+/)
      expect(fact_info['rpm']).to match(/^\d+\.\d+/)
    end
  end
end
