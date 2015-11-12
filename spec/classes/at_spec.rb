require 'spec_helper'

describe 'simplib::at' do

  it { should compile.with_all_deps }

  it { should create_concat_build('at').with_target('/etc/at.allow') }
  it { should create_file('/etc/at.allow').that_subscribes_to('Concat_build[at]') }
  it { should create_file('/etc/at.deny').with_ensure('absent') }
  it { should create_service('atd').with({
      :ensure     => 'running',
      :enable     => true,
      :hasrestart => true,
      :hasstatus  => true
    })
  }

end
