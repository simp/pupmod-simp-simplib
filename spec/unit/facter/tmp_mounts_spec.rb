# frozen_string_literal: true

require 'spec_helper'

describe 'tmp_mounts facts' do
  before :each do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    # Facter 4
    if defined?(Facter::Resolvers::Uname)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(any_args).and_return('Linux')
    else
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
    end

    # confine { File.directory?(dir) } passes for the target dirs
    allow(File).to receive(:directory?).with(any_args).and_call_original
    ['/tmp', '/var/tmp', '/dev/shm'].each do |dir|
      allow(File).to receive(:directory?).with(dir).and_return(true)
    end
  end

  context 'when simplib__mountpoints resolves to a Hash' do
    before :each do
      allow(Facter).to receive(:value).and_call_original
      allow(Facter).to receive(:value).with(:simplib__mountpoints).and_return(
        '/tmp' => {
          'device'     => 'tmpfs',
          'filesystem' => 'tmpfs',
          'options'    => ['rw', 'nosuid', 'nodev'],
        },
      )
    end

    it 'returns the mount options for tmp_mount_tmp' do
      expect(Facter.value('tmp_mount_tmp')).to eq('rw,nosuid,nodev')
    end

    it 'returns the device for tmp_mount_path_tmp' do
      expect(Facter.value('tmp_mount_path_tmp')).to eq('tmpfs')
    end

    it 'returns the filesystem for tmp_mount_fstype_tmp' do
      expect(Facter.value('tmp_mount_fstype_tmp')).to eq('tmpfs')
    end

    it 'returns nil for a dir that is not present in the Hash' do
      expect(Facter.value('tmp_mount_var_tmp')).to be_nil
    end
  end

  context 'when simplib__mountpoints resolves to nil' do
    before :each do
      allow(Facter).to receive(:value).and_call_original
      allow(Facter).to receive(:value).with(:simplib__mountpoints).and_return(nil)
    end

    # Regression: previously raised
    #   undefined method `[]' for nil:NilClass
    it 'returns nil without raising for tmp_mount_tmp' do
      expect { Facter.value('tmp_mount_tmp') }.not_to raise_error
      expect(Facter.value('tmp_mount_tmp')).to be_nil
    end

    it 'returns nil without raising for tmp_mount_path_var_tmp' do
      expect { Facter.value('tmp_mount_path_var_tmp') }.not_to raise_error
      expect(Facter.value('tmp_mount_path_var_tmp')).to be_nil
    end

    it 'returns nil without raising for tmp_mount_fstype_dev_shm' do
      expect { Facter.value('tmp_mount_fstype_dev_shm') }.not_to raise_error
      expect(Facter.value('tmp_mount_fstype_dev_shm')).to be_nil
    end
  end
end
