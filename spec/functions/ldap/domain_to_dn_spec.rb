require 'spec_helper'

describe 'simplib::ldap::domain_to_dn' do
  on_supported_os.each do |os, os_facts|
    context 'with a regular domain' do
      let(:facts) {
        os_facts[:networking][:domain] = 'test.domain'
        os_facts
      }

      it do
        expect( subject.execute() ).to eq 'DC=test,DC=domain'
      end
    end

    context 'with a short domain' do
      let(:facts) {
        os_facts[:networking][:domain] = 'domain'
        os_facts
      }

      it do
        expect( subject.execute() ).to eq 'DC=domain'
      end
    end

    context 'when passed a domain' do
      it do
        expect( subject.execute('test.domain') ).to eq 'DC=test,DC=domain'
      end
    end

    context 'when told to downcase the attributes' do
      it do
        expect( subject.execute('test.domain', true) ).to eq 'dc=test,dc=domain'
      end
    end
  end
end
