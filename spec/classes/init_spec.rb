require 'spec_helper'

describe 'simplib' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts){
        facts.merge({
        :fips_enabled => false,
        :boot_dir_uuid => '123-456-789'
      }) }


      context "on #{os}" do
        it {
          is_expected.to compile.with_all_deps
        }
        it { is_expected.to create_pam__limits__add('prevent_core') }
        it { is_expected.to create_pam__limits__add('max_logins') }
        it {
          is_expected.to create_mount('/proc').with_options('hidepid=2')
        }

        context 'no_core' do
          let(:params){{ :core_dumps => true }}
          it { is_expected.not_to create_pam__limits__add('prevent_core') }
        end

        context 'when_enabling_fips' do
          let(:params){{
            :use_fips => true
          }}

          it {
            is_expected.to compile.with_all_deps
          }
          it {
            is_expected.to create_kernel_parameter('fips').with_value('1')
            is_expected.to create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
            is_expected.to create_package('dracut-fips').with_ensure('latest')
            is_expected.to create_package('dracut-fips').that_notifies('Exec[dracut_rebuild]')
            is_expected.to create_package('fipscheck').with_ensure('latest')
          }
          it { is_expected.to create_kernel_parameter('boot').with_value("UUID=123-456-789") }
          it { is_expected.to create_kernel_parameter('boot').that_notifies('Reboot_notify[fips]') }
          it { is_expected.to create_reboot_notify('fips') }
        end

        context 'when_disabling_fips_and_fips_enabled' do
          let(:facts){ facts.merge({
              :fips_enabled => true,
              :boot_dir_uuid => '123-456-789'
          })}

          let(:params){{
            :use_fips => false
          }}

          it {
            is_expected.to compile.with_all_deps
          }
          it {
            is_expected.to create_kernel_parameter('fips').with_value('0')
            is_expected.to create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
          }
          it { is_expected.to create_reboot_notify('fips') }
        end

        context 'when_disabling_fips_and_fips_not_enabled' do
          let(:facts){ facts.merge({
            :fips_enabled => false,
            :boot_dir_uuid => '123-456-789'
          })}

          let(:params){{
            :use_fips => false
          }}

          it {
            is_expected.to compile.with_all_deps
          }
          it {
            is_expected.to create_kernel_parameter('fips').with_value('0')
            is_expected.to create_kernel_parameter('fips').that_notifies('Reboot_notify[fips]')
          }
          it { is_expected.to create_reboot_notify('fips') }
        end

        context 'when not managing /proc' do
          let(:params){{ :manage_proc => false }}

          it {
            is_expected.to_not create_mount('/proc')
          }
        end

        context 'when allowing the group "seepids" to see process IDs' do
          let(:params){{ :proc_gid => 'seepids'}}

          it {
            is_expected.to create_mount('/proc').with_options('hidepid=2,gid=seepids')
          }
        end
      end
    end
  end
end
