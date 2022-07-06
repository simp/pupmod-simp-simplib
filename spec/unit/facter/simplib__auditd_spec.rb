require 'spec_helper'

describe 'simplib__auditd' do
  before :each  do
    Facter.clear

    allow(Facter).to receive(:value).with(any_args).and_call_original
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
    allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
    expect(Facter::Util::Resolution).to receive(:which).with('ps').and_return('/bin/ps')
  end

  context 'with auditctl not present' do
    it do
      expect(Facter::Util::Resolution).to receive(:which).with('auditctl').and_return(nil)

      expect(Facter.fact('simplib__auditd').value).to be_nil
    end
  end

  context 'with auditctl present' do
    before :each  do
      expect(Facter::Util::Resolution).to receive(:which).with('auditctl').and_return('/sbin/auditctl')
    end

    context 'with audit disabled in the kernel' do
      it do
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -s').and_return("\n")
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -v').and_return("\n")
        expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '0'})

        expect(Facter.fact('simplib__auditd').value).to eq(
          {
            'enforcing'        => false,
            'kernel_enforcing' => false,
            'enabled'          => false
          }
        )
      end
    end

    context 'with auditd disabled and audit enabled in the kernel after reboot' do
      it do
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -v').and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -s').and_return("\n")
        expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '1'})

        expect(Facter.fact('simplib__auditd').value).to eq(
          {
            'enforcing'        => false,
            'kernel_enforcing' => true,
            'enabled'          => false,
            'version'          => '1.2.3'
          }
        )
      end
    end

    context 'after reboot where auditd was disabled before reboot' do
      before(:each) do
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -v').and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -s')
          .and_return( <<~AUDITCTL_S
                   enabled 0
                   failure 1
                   pid 1337
                   rate_limit 0
                   backlog_limit 64
                   lost 0
                   backlog 0
                   backlog_wait_time 60000
                   loginuid_immutable 0 unlocked
                   AUDITCTL_S
                  )
      end

      let(:simplib__auditd_value_explicit) do
        {
          'enforcing'          => false,
          'kernel_enforcing'   => true,
          'enabled'            => false,
          'version'            => '1.2.3',
          'failure'            => 1,
          'pid'                => 1337,
          'rate_limit'         => 0,
          'backlog_limit'      => 64,
          'lost'               => 0,
          'backlog'            => 0,
          'backlog_wait_time'  => 60000,
          'loginuid_immutable' => '0 unlocked'
        }
      end

      let(:simplib__auditd_value_implicit) do
        # without auditd running, in the absence of cmdline option,
        # have no way of knowing
        simplib__auditd_value_explicit.merge({'kernel_enforcing' => false})
      end

      context 'with audit explicitly enabled in the kernel' do
        it do
          expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '1'})
          expect(Facter.fact('simplib__auditd').value).to eq(simplib__auditd_value_explicit)
        end
      end

      context 'with audit implicitly enabled in the kernel' do
        it do
          expect(Facter).to receive(:value).with('cmdline').and_return({})
          expect(Facter.fact('simplib__auditd').value).to eq(simplib__auditd_value_implicit)
        end
      end

    end

    context 'with a properly functioning auditd' do
      before(:each) do
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -v').and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:exec).with('/sbin/auditctl -s')
          .and_return( <<~AUDITCTL_S
                   enabled 1
                   failure 1
                   pid 1337
                   rate_limit 0
                   backlog_limit 64
                   lost 0
                   backlog 0
                   backlog_wait_time 60000
                   loginuid_immutable 0 unlocked
                   AUDITCTL_S
                  )
        expect(Facter::Core::Execution).to receive(:exec).with('/bin/ps -e')
          .and_return( <<~PS_OUTPUT
            PID TTY          TIME CMD
              1 ?        00:00:04 systemd
              2 ?        00:00:00 kthreadd
              3 ?        00:00:00 kauditd
              4 ?        00:00:00 auditd
            PS_OUTPUT
           )
      end

      let(:simplib__auditd_value) do
        {
          'enforcing'          => true,
          'kernel_enforcing'   => true,
          'enabled'            => true,
          'version'            => '1.2.3',
          'failure'            => 1,
          'pid'                => 1337,
          'rate_limit'         => 0,
          'backlog_limit'      => 64,
          'lost'               => 0,
          'backlog'            => 0,
          'backlog_wait_time'  => 60000,
          'loginuid_immutable' => '0 unlocked'
        }
      end

      context 'with audit explicitly or implicitly enabled in the kernel' do
        it do
          expect(Facter.fact('simplib__auditd').value).to eq(simplib__auditd_value)
        end
      end
    end
  end
end
