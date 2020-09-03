# frozen_string_literal: true

require 'spec_helper'

describe 'init_systems' do
  before :each do
    Facter.clear
  end

  context 'when on a base system' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('initctl').returns(false)
      Facter::Util::Resolution.stubs(:which).with('systemctl').returns(false)
      Dir.stubs(:exist?).with('/etc/init.d').returns false
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc']) }
  end

  context 'with initctl' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('initctl').returns(true)
      Facter::Util::Resolution.stubs(:which).with('systemctl').returns(false)
      Dir.stubs(:exist?).with('/etc/init.d').returns(false)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'upstart']) }
  end

  context 'with systemctl' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('initctl').returns(false)
      Facter::Util::Resolution.stubs(:which).with('systemctl').returns(true)
      Dir.stubs(:exist?).with('/etc/init.d').returns(false)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'systemd']) }
  end

  context 'with /etc/init.d' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('initctl').returns(false)
      Facter::Util::Resolution.stubs(:which).with('systemctl').returns(false)
      Dir.stubs(:exist?).with('/etc/init.d').returns(true)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'sysv']) }
  end

  context 'with all' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('initctl').returns(true)
      Facter::Util::Resolution.stubs(:which).with('systemctl').returns(true)
      Dir.stubs(:exist?).with('/etc/init.d').returns(true)
    end

    it { expect(Facter.fact('init_systems').value).to eq(['rc', 'upstart', 'systemd', 'sysv']) }
  end
end
