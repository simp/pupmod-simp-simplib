require 'spec_helper'

describe "custom fact prelink" do
  let (:sysconfig_prelink_enabled) { <<EOM
# Set this to no to disable prelinking altogether
PRELINKING=yes
PRELINK_OPTS=-mR
EOM
  }

  let (:sysconfig_prelink_disabled) { <<EOM
# Set this to no to disable prelinking altogether
PRELINKING=no
PRELINK_OPTS=-mR
EOM
  }

  let (:sysconfig_prelink_unspecified) { <<EOM
# Set this to no to disable prelinking altogether
#PRELINKING=yes
PRELINK_OPTS=-mR
EOM
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')

    allow(File).to receive(:read).with(any_args).and_call_original
  end

  context '/etc/sysconfig/prelink enables prelinking' do
    it 'should return hash with enabled status' do
      expect(Facter::Core::Execution).to receive(:which).with('prelink').and_return('/usr/sbin/prelink')
      expect(File).to receive(:exist?).with('/etc/sysconfig/prelink').and_return(true)
      expect(File).to receive(:read).with('/etc/sysconfig/prelink').and_return(sysconfig_prelink_enabled)

      expect(Facter.fact('prelink').value).to eq({ 'enabled' => true })
    end
  end

  context '/etc/sysconfig/prelink disables prelinking' do
    it 'should return hash with disabled status' do
      expect(Facter::Core::Execution).to receive(:which).with('prelink').and_return('/usr/sbin/prelink')
      expect(File).to receive(:exist?).with('/etc/sysconfig/prelink').and_return(true)
      expect(File).to receive(:read).with('/etc/sysconfig/prelink').and_return(sysconfig_prelink_disabled)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink does not specify prelinking action' do
    it 'should return hash with disabled status' do
      expect(Facter::Core::Execution).to receive(:which).with('prelink').and_return('/usr/sbin/prelink')
      expect(File).to receive(:exist?).with('/etc/sysconfig/prelink').and_return(true)
      expect(File).to receive(:read).with('/etc/sysconfig/prelink').and_return(sysconfig_prelink_unspecified)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink is absent' do
    it 'should return hash with disabled status' do
      expect(Facter::Core::Execution).to receive(:which).with('prelink').and_return('/usr/sbin/prelink')
      expect(File).to receive(:exist?).with('/etc/sysconfig/prelink').and_return(false)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context 'prelink executable is not available' do
    it 'should return nil' do
      expect(Facter::Core::Execution).to receive(:which).with('prelink').and_return(nil)

      expect(Facter.fact('prelink').value).to be nil
    end
  end
end
