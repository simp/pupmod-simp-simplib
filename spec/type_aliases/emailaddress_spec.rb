require 'spec_helper'

describe 'Simplib::EmailAddress' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('user@example.com') }
        it { is_expected.to allow_value('a@b') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('user') }
        it { is_expected.not_to allow_value('@example.com') }
        it { is_expected.not_to allow_value('user@') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("user@example.com\nevil") }
        it { is_expected.not_to allow_value("evil\nuser@example.com") }
        it { is_expected.not_to allow_value("user@example.com\n") }
      end
    end
  end
end
