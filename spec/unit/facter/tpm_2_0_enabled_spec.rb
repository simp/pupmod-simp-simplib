require 'spec_helper'
require 'pry'

describe 'tpm_2_0_enabled', :type => :fact do
  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context 'tpm2-tools package is not installed' do
    it 'should return nil' do
      Facter::Core::Execution.stubs(:which).with('tpm2_getcap').returns nil
      expect(Facter.fact(:tpm_2_0_enabled).value).to eq nil
    end
  end

  context 'tpm2-tools package is installed' do
    before(:each) do
      # Just need something that actually exists on the current FS
      Facter::Core::Execution.stubs(:which).with('tpm2_getcap').returns Dir.pwd
    end

    let(:mocks_dir) { File.join(File.dirname(__FILE__), 'files', 'tpm2', 'mocks') }

    it 'should return true when TPM 2.0 is enabled' do
      fixed_props = File.read(File.join(mocks_dir, 'tpm2_getcap_-c_properties-fixed/nuvoton-ncpt6xx-fbfc85e.yaml'))
      Facter::Util::Resolution.stubs(:exec).with('tpm2_getcap -c properties-fixed').returns fixed_props
      expect(Facter.fact(:tpm_2_0_enabled).value).to be true
    end

    it 'should return false when TPM 2.0 is not enabled' do
      fixed_props = File.read(File.join(mocks_dir, 'tpm2_getcap_-c_properties-fixed/nuvoton-ncpt6xx-fbfc85e.yaml'))
      fixed_props.gsub!('"2.0"', '"2.1"')
      Facter::Util::Resolution.stubs(:exec).with('tpm2_getcap -c properties-fixed').returns fixed_props
      expect(Facter.fact(:tpm_2_0_enabled).value).to be false
    end
  end

end
