require 'spec_helper'

describe 'simplib::ktune' do

  it { should compile.with_all_deps }

  it { should contain_file('/etc/tuned.conf').with_content(/interval=10/) }
  it { should contain_file('/etc/tuned.conf').that_notifies('Service[tuned]') }
  it { should contain_file('/etc/sysconfig/ktune').with_content(/ELEVATOR="deadline"/) }
  it { should contain_file('/etc/sysctl.ktune') }
  it { should contain_package('tuned') }
  it { should contain_service('tuned').with({
      :require => ['Package[tuned]','File[/etc/sysconfig/ktune]']
    })
  }

end
