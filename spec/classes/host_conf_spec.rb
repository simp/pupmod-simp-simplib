require 'spec_helper'

describe 'simplib::host_conf' do

  it { should compile.with_all_deps }
  it { should create_file('/etc/host.conf').with_content(<<-EOM.gsub(/^\s+/,''))
       multi on
       spoof warn
       reorder on
       EOM
  }

  context 'with_trim' do
    let(:params){{ :trim => ['.bar.baz','.alpha.beta'] }}
    it { should create_file('/etc/host.conf').with_content(<<-EOM.gsub(/^\s+/,''))
       multi on
       spoof warn
       reorder on
       trim .bar.baz,.alpha.beta
       EOM
    }
  end

  context 'with_bad_trim' do
    let(:params){{ :trim => ['bar.baz'] }}
    it {
      expect {
      should compile.with_all_deps
      }.to raise_error(/"bar.baz" does not match/)
    }
  end
end
