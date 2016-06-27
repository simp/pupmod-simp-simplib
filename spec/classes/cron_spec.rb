require 'spec_helper'

describe 'simplib::cron' do
  on_supported_os.each do |os, facts|
    let(:facts){ facts }

    context "on #{os}" do
      describe 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to create_concat_build('cron').with_target('/etc/cron.allow') }
        it { is_expected.to create_file('/etc/cron.allow').that_subscribes_to('Concat_build[cron]') }
        it { is_expected.to create_file('/etc/cron.deny').with_ensure('absent') }
        it { is_expected.to create_rsync('cron') }

        context 'no_rsync' do
          let(:params){{ :use_rsync => false }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to create_rsync('cron') }
        end

        if facts['operatingsystemmajrelease' == 6 ]
          it { is_expected.to contain_package('tmpwatch') }
        else
          it { is_expected.not_to contain_package('tmpwatch') }
        end
      end
    end

  end
end
