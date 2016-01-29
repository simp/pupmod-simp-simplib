require 'spec_helper'

describe 'simplib::modprobe_blacklist' do
  let(:facts){{
    :operatingsystem => 'CentOS',
    :operatingsystemrelease => '6.5',
    :operatingsystemmajrelease => '6'
  }}

  it { is_expected.to compile.with_all_deps }

  context 'disable' do
    let(:params){{ :enable => false }}
    it { is_expected.to create_file('/etc/modprobe.d/00_simp_blacklist.conf').with_ensure('absent') }
  end

end
