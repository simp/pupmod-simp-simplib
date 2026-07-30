require 'spec_helper'

describe 'Simplib::Libcrypt::SHA1' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$sha1$40000$jtNX3nZ2$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$sha1$40000$jtNX3nZ2$tooshort') }
        it { is_expected.not_to allow_value('$sha1$0$salt$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$sha1$40000$jtNX3nZ2$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\n$sha1$40000$jtNX3nZ2$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("$sha1$40000$jtNX3nZ2$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n") }
      end
    end
  end
end
