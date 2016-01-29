require 'spec_helper'

describe 'simplib::issue' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file('/etc/issue').with_source('puppet:///modules/simplib/etc/issue') }
  it { is_expected.to contain_file('/etc/issue.net').with_source('file:///etc/issue') }

  context 'specified content' do
    let(:params){{
      :content => 'foo bar',
      :net_content => 'bar baz'
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/issue').with_content(params[:content]) }
    it { is_expected.to contain_file('/etc/issue.net').with_content(params[:net_content]) }
  end

  context 'specified rsync source' do
    let(:params){{
      :source => 'rsync',
      :net_source => 'rsync'
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/issue') }
    it { is_expected.to contain_file('/etc/issue').that_requires('Rsync[/etc/issue]') }
    it { is_expected.to contain_rsync('/etc/issue').with_source('default/global_etc/issue') }
    it { is_expected.to contain_file('/etc/issue.net') }
    it { is_expected.to contain_file('/etc/issue.net').that_requires('Rsync[/etc/issue.net]') }
    it { is_expected.to contain_rsync('/etc/issue.net').with_source('default/global_etc/issue.net') }
  end
end
