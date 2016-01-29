require 'spec_helper'

describe 'simplib::at' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_concat_build('at').with_target('/etc/at.allow') }
      it { is_expected.to create_file('/etc/at.allow').that_subscribes_to('Concat_build[at]') }
      it { is_expected.to create_file('/etc/at.deny').with_ensure('absent') }
      it { is_expected.to create_service('atd').with({
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true,
          :hasstatus  => true
        })
      }
    end
  end
end
