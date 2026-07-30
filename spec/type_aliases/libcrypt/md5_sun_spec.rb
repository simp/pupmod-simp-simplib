require 'spec_helper'

describe 'Simplib::Libcrypt::MD5_Sun' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$md5$RPgLF6IJ$aaaaaaaaaaaaaaaaaaaaaa') }
        it { is_expected.to allow_value('$md5,rounds=5000$RPgLF6IJ$aaaaaaaaaaaaaaaaaaaaaa') }
        it { is_expected.to allow_value('$md5$RPgLF6IJ$$aaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$md5$RPgLF6IJ$short') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$md5$RPgLF6IJ$aaaaaaaaaaaaaaaaaaaaaa\nevil") }
        it { is_expected.not_to allow_value("evil\n$md5$RPgLF6IJ$aaaaaaaaaaaaaaaaaaaaaa") }
        it { is_expected.not_to allow_value("$md5$RPgLF6IJ$aaaaaaaaaaaaaaaaaaaaaa\n") }
      end
    end
  end
end
