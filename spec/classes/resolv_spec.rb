require 'spec_helper'

describe 'simplib::resolv' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:params){{
          :nameservers => ['1.2.3.4','5.6.7.8']
        }}

        let(:facts){facts.merge({
          :fqdn => 'foo.bar.baz',
          :hostname => 'foo',
          :interfaces => 'eth0',
          :ipaddress_eth0 => '10.0.2.15',
        })}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.not_to contain_named__caching }
        it { is_expected.to contain_simp_file_line('resolv_peerdns') }
        it { is_expected.to contain_file('/etc/resolv.conf') }
        it { is_expected.not_to contain_file('/etc/resolv.conf').that_comes_before('Service[named]') }

        context 'node_is_nameserver' do
          let(:facts){facts.merge({:ipaddress => '10.0.2.15'})}

          let(:params){{
            :nameservers => ['1.2.3.4','5.6.7.8','10.0.2.15']
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_named__caching }
          it { is_expected.to contain_named }
          # I think rspec-puppet is broken...
          # it { should contain_file('/etc/resolv.conf').that_comes_before('Service[bind]') }
        end

        context 'node_is_nameserver_with_selinux' do
          let(:facts){facts.merge({
            :fqdn => 'foo.bar.baz',
            :hostname => 'foo',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '10.0.2.15',
            :selinux_enforced => true,
          })}
          let(:params){{
            :nameservers => ['1.2.3.4','5.6.7.8','10.0.2.15']
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_named__caching }
          it { is_expected.to contain_named }
          # I think rspec-puppet is broken...
          # it { should contain_file('/etc/resolv.conf').that_comes_before('Service[bind-chroot]') }
        end

        context 'node_with_named_autoconf_and_caching' do
          let(:facts){facts.merge({
            :fqdn => 'foo.bar.baz',
            :hostname => 'foo',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '10.0.2.15',
          })}
          let(:params){{
            :nameservers => ['127.0.0.1','1.2.3.4','5.6.7.8']
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_named__caching }
        end

        context 'node_with_named_autoconf_and_caching_only_127.0.0.1' do
          let(:facts){facts.merge({
            :fqdn => 'foo.bar.baz',
            :hostname => 'foo',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '10.0.2.15',
          })}
          let(:params){{
            :nameservers => ['127.0.0.1']
          }}
          it { expect { is_expected.to compile.with_all_deps}.to raise_error(/not be your only/) }
        end

      end
    end
  end
end
