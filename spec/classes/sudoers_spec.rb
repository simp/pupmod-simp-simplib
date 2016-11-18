require 'spec_helper'

describe 'simplib::sudoers' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      let(:facts){ os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('sudo') }
    end
  end
end
