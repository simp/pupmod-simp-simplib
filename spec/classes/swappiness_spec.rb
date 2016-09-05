require 'spec_helper'

describe 'simplib::swappiness' do
  context 'supported operating systems' do
    on_supported_os.each do |os,facts|
      context "on #{os}" do
        let(:facts){ facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to create_file('/usr/local/sbin/dynamic_swappiness.rb') }
        it { is_expected.to create_cron('dynamic_swappiness') }
        it { is_expected.not_to create_sysctl('vm.swappiness') }

        context 'absolute_swappiness' do
          let(:params){{ :absolute_swappiness => '10' }}
          it { is_expected.to contain_file('/usr/local/sbin/dynamic_swappiness.rb').with_ensure('absent') }
          it { is_expected.to create_cron('dynamic_swappiness').with(:ensure => 'absent') }
          it { is_expected.to create_sysctl('vm.swappiness').with_value('10') }
        end
      end
    end
  end
end
