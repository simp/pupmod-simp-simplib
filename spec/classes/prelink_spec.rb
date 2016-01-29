require 'spec_helper'

describe 'simplib::prelink' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file('/etc/sysconfig/prelink').with_content(/PRELINKING=no/) }

end
