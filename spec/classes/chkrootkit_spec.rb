require 'spec_helper'

describe 'simplib::chkrootkit' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_cron('chkrootkit').with_command('/usr/sbin/chkrootkit -n | /bin/logger -p local6.notice -t chkrootkit') }
  it { is_expected.to create_package('chkrootkit') }

  context 'no_syslog' do
    let(:params) {{ :destination => 'cron' }}
    it { is_expected.to create_cron('chkrootkit').with_command('/usr/sbin/chkrootkit -n') }
  end

end
