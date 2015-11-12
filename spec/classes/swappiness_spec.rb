require 'spec_helper'

describe 'simplib::swappiness' do

  it { should compile.with_all_deps }

  it { should create_file('/usr/local/sbin/dynamic_swappiness.rb') }
  it { should create_cron('dynamic_swappiness') }
  it { should_not create_sysctl__value('vm.swappiness') }

  context 'absolute_swappiness' do
    let(:params){{ :absolute_swappiness => '10' }}
    it { should_not create_file('/usr/local/sbin/dynamic_swappiness.rb') }
    it { should create_cron('dynamic_swappiness').with(:ensure => 'absent') }
    it { should create_sysctl__value('vm.swappiness').with_value('10') }
  end
end
