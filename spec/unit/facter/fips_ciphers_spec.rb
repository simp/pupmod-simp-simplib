require 'spec_helper'

describe 'fips_ciphers' do

  before :each do
    Facter.clear
    expect(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
  end

  context 'openssl command exists' do
    it 'returns FIPS ciphers' do
      expect(Facter::Core::Execution).to receive(:which).with('openssl').and_return('/bin/openssl')
      expect(Facter::Core::Execution).to receive(:exec).with('/bin/openssl ciphers FIPS:-LOW').and_return("ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA")
      expect(Facter.fact('fips_ciphers').value).to eq(["ECDHE-RSA-AES256-GCM-SHA384","ECDHE-ECDSA-AES256-GCM-SHA384","ECDHE-RSA-AES256-SHA384","ECDHE-ECDSA-AES256-SHA384","ECDHE-RSA-AES256-SHA"])
    end
  end

  context 'openssl command does not exist' do
    it 'returns nil' do
      expect(Facter::Core::Execution).to receive(:which).with('openssl').and_return(nil)
      expect(Facter.fact('fips_ciphers').value).to eq(nil)
    end
  end

end
