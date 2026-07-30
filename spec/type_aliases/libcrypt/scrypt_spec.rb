require 'spec_helper'

describe 'Simplib::Libcrypt::Scrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$7$C6..../....SodiumChloride$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$7$short$aaa') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$7$C6..../....SodiumChloride$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\n$7$C6..../....SodiumChloride$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("$7$C6..../....SodiumChloride$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n") }
      end
    end
  end
end
