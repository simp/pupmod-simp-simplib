require 'spec_helper'

describe 'simplib::timezone' do

  let(:params){{ :zone => 'foo' }}

  it { should compile.with_all_deps }
  it { should create_file('/etc/localtime').with_source("/usr/share/zoneinfo/#{params[:zone]}") }

end
