require 'spec_helper'

describe 'simplib::chkrootkit' do

  it { should compile.with_all_deps }
  it { should create_cron('chkrootkit').with_command('/usr/sbin/chkrootkit -n | /bin/logger -p local6.notice -t chkrootkit') }
  it { should create_package('chkrootkit') }

  context 'no_syslog' do
    let(:params) {{ :destination => 'cron' }}
    it { should create_cron('chkrootkit').with_command('/usr/sbin/chkrootkit -n') }
  end

end
