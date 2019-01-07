require 'spec_helper'
require 'facter/tpm2'
require 'facter/tpm2/util'
require 'ostruct'

describe 'tpm2', :type => :fact do

  before :all do
    @l_bin = '/usr/local/bin'
    @u_bin = '/usr/bin'
  end

  let(:mocks_dir) { File.join(File.dirname(__FILE__), 'files', 'tpm2', 'mocks') }

  context 'when the hardware TPM is TPM 1.2' do
    it 'should return nil' do
      Facter.stubs(:value).with(:has_tpm).returns true
      Facter.stubs(:value).with(:tpm).returns({ :tpm1_hash => :values })
      Facter::Core::Execution.stubs(:execute).with(%r{uname$}).returns true
      Facter::Core::Execution.stubs(:execute).with(%r{.*/?tpm_version$}, :timeout => 15).returns nil
#      expect(Facter).to receive(:fact).with(:tpm2).and_call_original

      expect(Facter.fact(:tpm2).value).to eq nil
    end
  end

  context 'when tpm2-tools is not installed' do
    it 'should return nil' do
      Facter.stubs(:value).with(:has_tpm).returns true
      Facter.stubs(:value).with(:tpm).returns nil
      File.stubs(:executable?).with("#{@l_bin}/tpm2_pcrlist").returns false
      File.stubs(:executable?).with("#{@u_bin}/tpm2_pcrlist").returns true

      expect(Facter.fact(:tpm2).value).to eq nil
    end
  end

  context 'The hardware TPM is TPM 2.0' do
    it 'should return a fact' do
      Facter.stubs(:value).with(:has_tpm).returns true
      Facter.stubs(:value).with(:tpm).returns nil
      File.stubs(:executable?).with("#{@l_bin}/tpm2_pcrlist").returns false
      File.stubs(:executable?).with("#{@u_bin}/tpm2_pcrlist").returns true
      Facter.stubs(:value).with(:has_tpm).returns true
      Facter::Core::Execution.stubs(:execute).with("#{@u_bin}/tpm2_getcap -c properties-fixed").returns(
        File.read(File.join(mocks_dir, 'tpm2_getcap_-c_properties-fixed/nuvoton-ncpt6xx-fbfc85e.yaml'))
      )

      Facter::Core::Execution.stubs(:execute).with("#{@u_bin}/tpm2_getcap -c properties-variable").returns(
        File.read(File.join(mocks_dir, 'tpm2_getcap_-c_properties-variable/clear-clear-clear.yaml'))
      )

      Facter::Core::Execution.stubs(:execute).with("#{@u_bin}/tpm2_pcrlist -s").returns(
          "Supported Bank/Algorithm: sha1(0x0004) sha256(0x000b) sha384(0x000c)\n"
        )
      fact = Facter.fact(:tpm2).value
      expect(fact).to be_a(Hash)
      expect(fact['manufacturer']).to match(/.{0,4}/)
      expect(fact['firmware_version']).to match(/^\d+\.\d+\.\d+\.\d+$/)
      expect(fact['tpm2_getcap']['properties-fixed']).to be_a(Hash)
      expect(fact['tpm2_getcap']['properties-variable']).to be_a(Hash)
    end
  end
end
