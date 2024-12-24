require 'spec_helper'

describe 'simplib__firewalls' do
  before :each do
    Facter.clear
    allow(Facter::Util::Resolution).to receive(:which).with(any_args).and_call_original
    expect(Facter::Util::Resolution).to receive(:which).with('firewalld').and_return('/usr/bin/firewalld')
    expect(Facter::Util::Resolution).to receive(:which).with('iptables').and_return(nil)
    expect(Facter::Util::Resolution).to receive(:which).with('nft').and_return('/usr/bin/nft')
    expect(Facter::Util::Resolution).to receive(:which).with('pfctl').and_return('/bin/pfctl')
  end

  it { expect(Facter.fact('simplib__firewalls').value).to eq(['firewalld', 'nft', 'pf']) }
end
