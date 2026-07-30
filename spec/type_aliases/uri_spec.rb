require 'spec_helper'

describe 'Simplib::URI' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('https://example.com/x') }
        it { is_expected.to allow_value('ldap://example.com:389') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('example.com') }
        it { is_expected.not_to allow_value('://example.com') }
        it { is_expected.not_to allow_value('1http://example.com') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("https://example.com/x\nevil") }
        it { is_expected.not_to allow_value("evil\nhttps://example.com/x") }
        it { is_expected.not_to allow_value("https://example.com/x\n") }
      end
    end
  end
end
