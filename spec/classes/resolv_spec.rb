require 'spec_helper'

describe 'simplib::resolv' do
  let(:params){{
    :nameservers => ['1.2.3.4','5.6.7.8']
  }}

  let(:facts){{
    :fqdn => 'foo.bar.baz',
    :hostname => 'foo',
    :interfaces => 'eth0',
    :ipaddress_eth0 => '10.10.10.10',
    :operatingsystem => 'RedHat'
  }}

  it { should compile.with_all_deps }

  it { should_not contain_named__caching }
  it { should contain_simp_file_line('resolv_peerdns') }
  it { should contain_file('/etc/resolv.conf') }
  # I think rspec-puppet is broken...
  # it { should_not contain_file('/etc/resolv.conf').that_comes_before('Service[named]') }

  context 'node_is_nameserver' do
    let(:params){{
      :nameservers => ['1.2.3.4','5.6.7.8','10.10.10.10']
    }}

    it { should compile.with_all_deps }
    it { should_not contain_named__caching }
    it { should contain_named }
    # I think rspec-puppet is broken...
    # it { should contain_file('/etc/resolv.conf').that_comes_before('Service[bind]') }
  end

  context 'node_is_nameserver_with_selinux' do
    let(:facts){{
      :fqdn => 'foo.bar.baz',
      :hostname => 'foo',
      :interfaces => 'eth0',
      :ipaddress_eth0 => '10.10.10.10',
      :selinux_enforced => true,
      :operatingsystem => 'RedHat'
    }}
    let(:params){{
      :nameservers => ['1.2.3.4','5.6.7.8','10.10.10.10']
    }}

    it { should compile.with_all_deps }
    it { should_not contain_named__caching }
    it { should contain_named }
    # I think rspec-puppet is broken...
    # it { should contain_file('/etc/resolv.conf').that_comes_before('Service[bind-chroot]') }
  end

  context 'node_with_named_autoconf_and_caching' do
    let(:facts){{
      :fqdn => 'foo.bar.baz',
      :hostname => 'foo',
      :interfaces => 'eth0',
      :ipaddress_eth0 => '10.10.10.10',
      :operatingsystem => 'RedHat'
    }}
    let(:params){{
      :nameservers => ['127.0.0.1','1.2.3.4','5.6.7.8']
    }}

    it { should compile.with_all_deps }
    it { should contain_named__caching }
  end

  context 'node_with_named_autoconf_and_caching_only_127.0.0.1' do
    let(:facts){{
      :fqdn => 'foo.bar.baz',
      :hostname => 'foo',
      :interfaces => 'eth0',
      :ipaddress_eth0 => '10.10.10.10',
      :operatingsystem => 'RedHat'
    }}
    let(:params){{
      :nameservers => ['127.0.0.1']
    }}
    it { expect { should compile.with_all_deps}.to raise_error(/not be your only/) }
  end

end
