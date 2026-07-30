require 'spec_helper'

describe 'Simplib::Libcrypt::Bigcrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('a' * 13) }
        it { is_expected.to allow_value('a' * 178) }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('a' * 12) }
        it { is_expected.not_to allow_value('a' * 179) }
        it { is_expected.not_to allow_value("#{'a' * 12}$") }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("#{'a' * 13}\nevil") }
        it { is_expected.not_to allow_value("evil\n#{'a' * 13}") }
        it { is_expected.not_to allow_value("#{'a' * 13}\n") }
      end
    end
  end
end
