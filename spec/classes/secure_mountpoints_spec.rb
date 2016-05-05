require 'spec_helper'

describe 'simplib::secure_mountpoints' do
  on_supported_os({:selinux_mode => :disabled}).each do |os, base_facts|

    context "on #{os}" do
      let(:facts){ base_facts.dup }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_mount('/dev/pts').with_options('rw,gid=5,mode=620,noexec') }
      it { is_expected.to contain_mount('/sys').with_options('rw,nodev,noexec') }
      it { is_expected.to contain_mount('/tmp').with({
        :options => 'bind,nodev,noexec,nosuid',
        :device  => '/tmp'
      })}
      it { is_expected.to contain_mount('/var/tmp').with({
        :options => 'bind,nodev,noexec,nosuid',
        :device  => '/tmp'
      })}

      context 'tmp_is_partition' do

        let(:facts){
          new_facts = base_facts.dup
          new_facts[:tmp_mount_tmp] = 'rw,seclabel,relatime,data=ordered'
          new_facts[:tmp_mount_fstype_tmp] = 'ext4'
          new_facts[:tmp_mount_path_tmp] = '/dev/sda3'

          new_facts}

        it {
          is_expected.to contain_mount('/tmp').with({
          :options => 'data=ordered,nodev,noexec,nosuid,relatime,rw',
          :device  => '/dev/sda3'
        })}
      end

      context 'tmp_is_already_bind_mounted' do
        new_facts = base_facts.dup
        new_facts[:tmp_mount_tmp] = 'bind,foo'
        new_facts[:tmp_mount_fstype_tmp] = 'ext4'
        new_facts[:tmp_mount_path_tmp] = '/tmp'

        let(:facts){new_facts}

        it { is_expected.to contain_mount('/tmp').with({
          :options => "bind,nodev,noexec,nosuid",
          :device  => '/tmp'
        })}
      end

      context 'var_tmp_is_partition' do
        new_facts = base_facts.dup
        new_facts[:tmp_mount_var_tmp] = 'rw,seclabel,relatime,data=ordered'
        new_facts[:tmp_mount_fstype_var_tmp] = 'ext4'
        new_facts[:tmp_mount_path_var_tmp] = '/dev/sda3'

        let(:facts){new_facts}

        it { is_expected.to contain_mount('/var/tmp').with({
          :options => 'data=ordered,nodev,noexec,nosuid,relatime,rw',
          :device  => '/dev/sda3'
        })}
      end

      context 'var_tmp_is_already_bind_mounted' do
        new_facts = base_facts.dup
        new_facts[:tmp_mount_var_tmp] = 'bind,foo'
        new_facts[:tmp_mount_fstype_var_tmp] = 'ext4'
        new_facts[:tmp_mount_path_var_tmp] = '/var/tmp'

        let(:facts){new_facts}

        it { is_expected.to contain_mount('/var/tmp').with({
          :options => "bind,nodev,noexec,nosuid",
          :device  => new_facts[:tmp_mount_path_var_tmp]
        })}
      end

      context 'tmp_mount_dev_shm_mounted' do
        new_facts = base_facts.dup
        new_facts[:tmp_mount_dev_shm] = 'rw,seclabel,nosuid,nodev'
        new_facts[:tmp_mount_fstype_dev_shm] = 'tmpfs'
        new_facts[:tmp_mount_path_dev_shm] = 'tmpfs'

        let(:facts){new_facts}

        it { is_expected.to contain_mount('/dev/shm').with({
          :options => 'nodev,noexec,nosuid,rw',
          :device  => new_facts[:tmp_mount_path_dev_shm]
        })}
      end
    end
  end
end
