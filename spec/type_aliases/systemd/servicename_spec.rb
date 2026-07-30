require 'spec_helper'

describe 'Simplib::Systemd::ServiceName' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('sshd.service') }
        it { is_expected.to allow_value('foo@bar.service') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('bad name.service') }
        it { is_expected.not_to allow_value('bad/name.service') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("sshd.service\nevil") }
        it { is_expected.not_to allow_value("evil\nsshd.service") }
        it { is_expected.not_to allow_value("sshd.service\n") }
      end
    end
  end
end
