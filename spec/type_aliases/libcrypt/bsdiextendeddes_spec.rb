require 'spec_helper'

describe 'Simplib::Libcrypt::BSDIExtendedDES' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('_aaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('_aaaaaaaaaaaaaaaaaa') }
        it { is_expected.not_to allow_value('aaaaaaaaaaaaaaaaaaaa') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("_aaaaaaaaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\n_aaaaaaaaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("_aaaaaaaaaaaaaaaaaaa\n") }
      end
    end
  end
end
