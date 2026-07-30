require 'spec_helper'

describe 'Simplib::Umask' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('077') }
        it { is_expected.to allow_value('0077') }
        it { is_expected.to allow_value('000') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('0778') }
        it { is_expected.not_to allow_value('08') }
        it { is_expected.not_to allow_value('00000') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("077\nevil") }
        it { is_expected.not_to allow_value("evil\n077") }
        it { is_expected.not_to allow_value("077\n") }
      end
    end
  end
end
