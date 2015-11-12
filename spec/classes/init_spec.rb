require 'spec_helper'

describe 'simplib' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts){{
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.5',
        :operatingsystemmajrelease => '6',
        :fips_enabled => false,
        :boot_dir_uuid => '123-456-789'
      }}


      context "on #{os}" do
        context "with default parameters" do
          it {
            should compile.with_all_deps
          }
          it { should create_pam__limits__add('prevent_core') }
          it { should create_pam__limits__add('max_logins') }
        end

        context 'no_core' do
          let(:params){{ :core_dumps => true }}
          it { should_not create_pam__limits__add('prevent_core') }
        end

        context 'when_enabling_fips' do
          let(:params){{
            :use_fips => true
          }}

          it {
            should compile.with_all_deps
          }
          it {
            should create_kernel_parameter('fips').with_value('1')
            should create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
            should create_package('dracut-fips').with_ensure('latest')
            should create_package('dracut-fips').that_notifies('Exec[dracut_rebuild]')
            should create_package('fipscheck').with_ensure('latest')
          }
          it { should create_kernel_parameter('boot').with_value("UUID=123-456-789") }
          it { should create_kernel_parameter('boot').that_notifies('Reboot_notify[fips]') }
          it { should create_reboot_notify('fips') }
        end

        context 'when_disabling_fips_and_fips_enabled' do
          let(:facts){ facts.merge({
              :osfamily => 'RedHat',
              :operatingsystem => 'CentOS',
              :operatingsystemrelease => '6.5',
              :operatingsystemmajrelease => '6',
              :fips_enabled => true,
              :boot_dir_uuid => '123-456-789'
          })}

          let(:params){{
            :use_fips => false
          }}

          it {
            should compile.with_all_deps
          }
          it {
            should create_kernel_parameter('fips').with_value('0')
            should create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
          }
          it { should create_reboot_notify('fips') }
        end

        context 'when_disabling_fips_and_fips_not_enabled' do
          let(:facts){ facts.merge({
            :osfamily => 'RedHat',
            :operatingsystem => 'CentOS',
            :operatingsystemrelease => '6.5',
            :operatingsystemmajrelease => '6',
            :fips_enabled => false,
            :boot_dir_uuid => '123-456-789'
          })}

          let(:params){{
            :use_fips => false
          }}

          it {
            should compile.with_all_deps
          }
          it {
            should create_kernel_parameter('fips').with_value('0')
            should create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
          }
          it { should create_reboot_notify('fips') }
        end
      end
    end
  end
end
