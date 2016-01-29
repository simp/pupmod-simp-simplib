require 'spec_helper'

describe 'simplib::host_conf' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_file('/etc/host.conf').with_content(<<-EOM.gsub(/^\s+/,''))
       multi on
       spoof warn
       reorder on
       EOM
  }

  context 'with_trim' do
    let(:params){{ :trim => ['.bar.baz','.alpha.beta'] }}
    it { is_expected.to create_file('/etc/host.conf').with_content(<<-EOM.gsub(/^\s+/,''))
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
      is_expected.to compile.with_all_deps
      }.to raise_error(/"bar.baz" does not match/)
    }
  end
end
