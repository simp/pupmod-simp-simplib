require 'spec_helper'

describe 'fips_ciphers' do
  before :each do
    Facter.clear

    allow(Facter::Core::Execution).to receive(:execute).with(any_args).and_call_original
  end

  let(:ciphers) do
    [
      'ECDHE-RSA-AES256-GCM-SHA384',
      'ECDHE-ECDSA-AES256-GCM-SHA384',
      'ECDHE-RSA-AES256-SHA384',
      'ECDHE-ECDSA-AES256-SHA384',
      'ECDHE-RSA-AES256-SHA',
    ]
  end

  context 'openssl command exists' do
    it 'returns FIPS ciphers' do
      expect(Facter::Core::Execution).to receive(:which).with('openssl').and_return('/bin/openssl')
      expect(Facter::Core::Execution).to receive(:execute).with("/bin/openssl ciphers 'FIPS:-3DES:-LOW:-NULL:-EXPORT:-aNULL'", on_fail: nil)
                                                          .and_return(ciphers.join(':'))
      expect(Facter.fact('fips_ciphers').value).to eq(ciphers)
    end
  end

  context 'openssl command does not exist' do
    it 'returns nil' do
      expect(Facter::Core::Execution).to receive(:which).with('openssl').and_return(nil)
      expect(Facter.fact('fips_ciphers').value).to eq(nil)
    end
  end
end
