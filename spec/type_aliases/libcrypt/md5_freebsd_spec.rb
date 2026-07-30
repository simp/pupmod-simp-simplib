require 'spec_helper'

describe 'Simplib::Libcrypt::MD5_FreeBSD' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$1$0nIBDEfm$QNNyqbDS5ZkwScfmvI37z.') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$1$$aaaaaaaaaaaaaaaaaaaaaa') }
        it { is_expected.not_to allow_value('$1$0nIBDEfm$short') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$1$0nIBDEfm$QNNyqbDS5ZkwScfmvI37z.\nevil") }
        it { is_expected.not_to allow_value("evil\n$1$0nIBDEfm$QNNyqbDS5ZkwScfmvI37z.") }
        it { is_expected.not_to allow_value("$1$0nIBDEfm$QNNyqbDS5ZkwScfmvI37z.\n") }

        # The salt is a negated character class, which matches a newline even
        # when the pattern is anchored to the whole string, so a newline could
        # be smuggled into the middle of an otherwise valid value
        it { is_expected.not_to allow_value("$1$0nIB\nEfm$QNNyqbDS5ZkwScfmvI37z.") }
      end
    end
  end
end
