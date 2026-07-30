require 'spec_helper'

describe 'Simplib::Libcrypt::Bcrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$2a$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe') }
        it { is_expected.to allow_value('$2y$10$RT.Z68QWbhbg5.TOba4gGOBEvj6anWfvPBaU3F1HMHTSz5g75Vrme') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$2c$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe') }
        it { is_expected.not_to allow_value('$2a$7$short') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$2a$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe\nevil") }
        it { is_expected.not_to allow_value("evil\n$2a$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe") }
        it { is_expected.not_to allow_value("$2a$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe\n") }
      end
    end
  end
end
