require 'spec_helper'

describe 'Simplib::Libcrypt::DES' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('aaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('aaaaaaaaaaaa') }
        it { is_expected.not_to allow_value('aaaaaaaaaaaaaa') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("aaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\naaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("aaaaaaaaaaaaa\n") }
      end
    end
  end
end
