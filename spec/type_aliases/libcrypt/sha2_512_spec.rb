require 'spec_helper'

describe 'Simplib::Libcrypt::SHA2_512' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid entries' do
        it { is_expected.to allow_value('$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1') }
        it { is_expected.to allow_value('$6$rounds=5000$h6k81gwg$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') }
      end

      context 'with invalid entries' do
        it { is_expected.not_to allow_value('$6$') }
        it { is_expected.not_to allow_value('$6$salt$tooshort') }
      end

      context 'the pattern is anchored to the whole string' do
        # Regression: line anchors let any multi-line string containing a
        # single valid line satisfy the type. See #353.
        it { is_expected.not_to allow_value("$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1\nevil") }
        it { is_expected.not_to allow_value("evil\n$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1") }
        it { is_expected.not_to allow_value("$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1\n") }
      end
    end
  end
end
