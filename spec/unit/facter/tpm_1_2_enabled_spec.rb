require 'spec_helper'
require 'pry'

describe 'tpm_1_2_enabled', :type => :fact do
  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context 'tpm-tools package is not installed' do
    it 'should return nil' do
      Facter::Core::Execution.stubs(:which).with('tpm_version').returns nil
      expect(Facter.fact(:tpm_1_2_enabled).value).to eq nil
    end
  end

  context 'tpm-tools package is installed' do
    before(:each) do
      # Just need something that actually exists on the current FS
      Facter::Core::Execution.stubs(:which).with('tpm_version').returns Dir.pwd
    end

    it 'should return true when TPM 1.2 is enabled' do
      Facter::Util::Resolution.stubs(:exec).with('tpm_version').returns 'TPM 1.2 Version Info: Chip Version 1.2.3.91. Spec Level: 2'
      expect(Facter.fact(:tpm_1_2_enabled).value).to be true
    end

    it 'should return false when TPM 1.2 is not enabled' do
      Facter::Util::Resolution.stubs(:exec).with('tpm_version').returns 'TPM 0.9 Version Info: Chip Version 1.2.3.91. Spec Level: 2'
      expect(Facter.fact(:tpm_1_2_enabled).value).to be false
    end
  end

end
