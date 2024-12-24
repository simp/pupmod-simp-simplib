require 'spec_helper'

describe 'defaultgatewayiface' do
  before :each do
    Facter.clear
  end

  let(:ipv4route) do
    <<~EOM
      192.168.221.0/24 dev eth0  proto kernel  scope link  src 192.168.221.200#{' '}
      169.254.0.0/16 dev eth0  scope link  metric 1002#{' '}
      default via 192.168.221.1 dev eth0#{' '}
    EOM
  end

  context 'ip command exists' do
    before :each do
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
      expect(Facter::Util::Resolution).to receive(:which).with('ip').and_return('/usr/bin/ip')
    end

    it 'returns IP address of valid default route' do
      expect(Facter::Core::Execution).to receive(:exec).with('/usr/bin/ip route').and_return(ipv4route)
      expect(Facter.fact(:defaultgatewayiface).value).to eq('eth0')
    end

    it 'returns IP address of last valid default route' do
      multiple_defaults = ipv4route + 'default via 10.0.2.1 dev eth1'
      expect(Facter::Core::Execution).to receive(:exec).with('/usr/bin/ip route').and_return(multiple_defaults)
      expect(Facter.fact(:defaultgatewayiface).value).to eq('eth1')
    end

    it "returns 'unknown' when no default line exists" do
      bad_route = ipv4route.gsub('default', 'oops ')
      expect(Facter::Core::Execution).to receive(:exec).with('/usr/bin/ip route').and_return(bad_route)
      expect(Facter.fact(:defaultgatewayiface).value).to eq('unknown')
    end

    it "returns 'unknown' when device could not be extracted from the default line" do
      bad_route = ipv4route.gsub('dev eth0', 'dev ')
      expect(Facter::Core::Execution).to receive(:exec).with('/usr/bin/ip route').and_return(bad_route)
      expect(Facter.fact(:defaultgatewayiface).value).to eq('unknown')
    end
  end

  context 'ip command does not exist' do
    it "returns 'unknown'" do
      expect(Facter::Util::Resolution).to receive(:which).with('ip').and_return(nil)
      expect(Facter.fact(:defaultgatewayiface).value).to eq('unknown')
    end
  end
end
