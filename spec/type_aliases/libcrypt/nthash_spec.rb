require 'spec_helper'

describe 'Simplib::Libcrypt::NTHASH' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$3$$0480cf9c8755c691c629f6595c2e7238') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$3$0480cf9c8755c691c629f6595c2e7238') }
        it { is_expected.not_to allow_value('$3$$0480CF9C8755C691C629F6595C2E7238') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$3$$0480cf9c8755c691c629f6595c2e7238\nevil") }
        it { is_expected.not_to allow_value("evil\n$3$$0480cf9c8755c691c629f6595c2e7238") }
        it { is_expected.not_to allow_value("$3$$0480cf9c8755c691c629f6595c2e7238\n") }
      end
    end
  end
end
