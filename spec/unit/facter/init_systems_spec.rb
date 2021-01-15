# frozen_string_literal: true

require 'spec_helper'

describe 'init_systems' do
  before :each do
    Facter.clear
  end

  context 'when on a base system' do
    before(:each) do
      expect(Facter::Util::Resolution).to receive(:which).with('initctl').and_return(false)
      expect(Facter::Util::Resolution).to receive(:which).with('systemctl').and_return(false)
      expect(Dir).to receive(:exist?).with('/etc/init.d').and_return false
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc']) }
  end

  context 'with initctl' do
    before(:each) do
      expect(Facter::Util::Resolution).to receive(:which).with('initctl').and_return(true)
      expect(Facter::Util::Resolution).to receive(:which).with('systemctl').and_return(false)
      expect(Dir).to receive(:exist?).with('/etc/init.d').and_return(false)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'upstart']) }
  end

  context 'with systemctl' do
    before(:each) do
      expect(Facter::Util::Resolution).to receive(:which).with('initctl').and_return(false)
      expect(Facter::Util::Resolution).to receive(:which).with('systemctl').and_return(true)
      expect(Dir).to receive(:exist?).with('/etc/init.d').and_return(false)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'systemd']) }
  end

  context 'with /etc/init.d' do
    before(:each) do
      expect(Facter::Util::Resolution).to receive(:which).with('initctl').and_return(false)
      expect(Facter::Util::Resolution).to receive(:which).with('systemctl').and_return(false)
      expect(Dir).to receive(:exist?).with('/etc/init.d').and_return(true)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'sysv']) }
  end

  context 'with all' do
    before(:each) do
      expect(Facter::Util::Resolution).to receive(:which).with('initctl').and_return(true)
      expect(Facter::Util::Resolution).to receive(:which).with('systemctl').and_return(true)
      expect(Dir).to receive(:exist?).with('/etc/init.d').and_return(true)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'upstart', 'systemd', 'sysv']) }
  end
end
