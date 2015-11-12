require 'spec_helper'

describe 'simplib::cron' do
  on_supported_os.each do |os, facts|
    let(:facts){ facts }

    context "on #{os}" do
      describe 'with default parameters' do
        it { should compile.with_all_deps }

        it { should create_concat_build('cron').with_target('/etc/cron.allow') }
        it { should create_file('/etc/cron.allow').that_subscribes_to('Concat_build[cron]') }
        it { should create_file('/etc/cron.deny').with_ensure('absent') }
        it { should create_rsync('cron') }

        context 'no_rsync' do
          let(:params){{ :use_rsync => false }}
          it { should compile.with_all_deps }
          it { should_not create_rsync('cron') }
        end
      end
    end

  end
end
