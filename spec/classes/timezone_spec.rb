require 'spec_helper'

describe 'simplib::timezone' do

  let(:params){{ :zone => 'foo' }}

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_file('/etc/localtime').with_source("/usr/share/zoneinfo/#{params[:zone]}") }

end
