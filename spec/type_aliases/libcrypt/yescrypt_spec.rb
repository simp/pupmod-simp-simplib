require 'spec_helper'

describe 'Simplib::Libcrypt::Yescrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$y$j9T$aaaa$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$y$j9T$aaaa$short') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$y$j9T$aaaa$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\n$y$j9T$aaaa$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("$y$j9T$aaaa$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n") }
      end
    end
  end
end
