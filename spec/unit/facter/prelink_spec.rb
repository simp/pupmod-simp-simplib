require 'spec_helper'

describe "custom fact prelink" do
  let (:sysconfig_prelink_enabled) {
    [
      "# Set this to no to disable prelinking altogether\n",
      "PRELINKING=yes\n",
      "PRELINK_OPTS=-mR\n"
    ]
  }

  let (:sysconfig_prelink_disabled) {
    [
      "# Set this to no to disable prelinking altogether\n",
      "PRELINKING=no\n",
      "PRELINK_OPTS=-mR\n"
    ]
  }

  let (:sysconfig_prelink_unspecified) {
    [
      "# Set this to no to disable prelinking altogether\n",
      "#PRELINKING=yes\n",
      "PRELINK_OPTS=-mR\n"
    ]
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context '/etc/sysconfig/prelink enables prelinking' do
    it 'should return hash with enabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      IO.expects(:readlines).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_enabled)

      expect(Facter.fact('prelink').value).to eq({ 'enabled' => true })
    end
  end

  context '/etc/sysconfig/prelink disables prelinking' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      IO.expects(:readlines).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_disabled)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink does not specify prelinking action' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      IO.expects(:readlines).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_unspecified)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink is absent' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(false)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context 'prelink executable is not available' do
    it 'should return nil' do
      Facter::Core::Execution.expects(:which).with('prelink').returns(nil)

      expect(Facter.fact('prelink').value).to be nil
    end
  end
end
