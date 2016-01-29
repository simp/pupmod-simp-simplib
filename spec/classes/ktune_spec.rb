require 'spec_helper'

describe 'simplib::ktune' do

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_file('/etc/tuned.conf').with_content(/interval=10/) }
  it { is_expected.to contain_file('/etc/tuned.conf').that_notifies('Service[tuned]') }
  it { is_expected.to contain_file('/etc/sysconfig/ktune').with_content(/ELEVATOR="deadline"/) }
  it { is_expected.to contain_file('/etc/sysctl.ktune') }
  it { is_expected.to contain_package('tuned') }
  it { is_expected.to contain_service('tuned').with({
      :require => ['Package[tuned]','File[/etc/sysconfig/ktune]']
    })
  }

end
