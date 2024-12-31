require 'spec_helper'

describe 'simplib::ldap::domain_to_dn' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with a regular domain' do
        let(:facts) do
          os_facts[:networking][:domain] = 'test.domain'
          os_facts
        end

        it { is_expected.to run.and_return('DC=test,DC=domain') }
      end

      context 'with a short domain' do
        let(:facts) do
          os_facts[:networking][:domain] = 'domain'
          os_facts
        end

        it { is_expected.to run.and_return('DC=domain') }
      end

      context 'when passed a domain' do
        it { is_expected.to run.with_params('test.domain').and_return('DC=test,DC=domain') }
      end

      context 'when told to downcase the attributes' do
        it { is_expected.to run.with_params('test.domain', true).and_return('dc=test,dc=domain') }
      end
    end
  end
end
