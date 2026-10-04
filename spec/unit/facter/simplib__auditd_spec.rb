require 'spec_helper'

describe 'simplib__auditd' do
  before :each do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    allow(Facter::Resolvers::Uname).to receive(:resolve).with(any_args).and_return('Linux')

    allow(Facter).to receive(:value).with(any_args).and_call_original
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
    # Without simp/auditd installed, this fact gathers its own data.
    allow(Facter).to receive(:value).with('auditd_state').and_return(nil)
    expect(Facter::Core::Execution).to receive(:which).with('ps').and_return('/bin/ps')
  end

  context 'with auditctl not present' do
    it do
      expect(Facter::Core::Execution).to receive(:which).with('auditctl').and_return(nil)

      expect(Facter.fact('simplib__auditd').value).to be_nil
    end
  end

  context 'with auditctl present' do
    before :each do
      expect(Facter::Core::Execution).to receive(:which).with('auditctl').and_return('/sbin/auditctl')
    end

    context 'with audit disabled in the kernel' do
      it do
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -s', on_fail: nil).and_return("\n")
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -v', on_fail: nil).and_return("\n")
        expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '0' })

        expect(Facter.fact('simplib__auditd').value).to eq(
          {
            'enforcing'        => false,
            'kernel_enforcing' => false,
            'enabled'          => false,
          },
        )
      end
    end

    context 'with auditd disabled and audit enabled in the kernel after reboot' do
      it do
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -v', on_fail: nil).and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -s', on_fail: nil).and_return("\n")
        expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '1' })

        expect(Facter.fact('simplib__auditd').value).to eq(
          {
            'enforcing'        => false,
            'kernel_enforcing' => true,
            'enabled'          => false,
            'version'          => '1.2.3',
          },
        )
      end
    end

    context 'after reboot where auditd was disabled before reboot' do
      before(:each) do
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -v', on_fail: nil).and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -s', on_fail: nil)
                                                            .and_return(
                                                           [
                                                             'enabled 0',
                                                             'failure 1',
                                                             'pid 1337',
                                                             'rate_limit 0',
                                                             'backlog_limit 64',
                                                             'lost 0',
                                                             'backlog 0',
                                                             'backlog_wait_time 60000',
                                                             'loginuid_immutable 0 unlocked',
                                                           ].join("\n"),
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
          'backlog_wait_time'  => 60_000,
          'loginuid_immutable' => '0 unlocked',
        }
      end

      let(:simplib__auditd_value_implicit) do
        # without auditd running, in the absence of cmdline option,
        # have no way of knowing
        simplib__auditd_value_explicit.merge({ 'kernel_enforcing' => false })
      end

      context 'with audit explicitly enabled in the kernel' do
        it do
          expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '1' })
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
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -v', on_fail: nil).and_return("1.2.3\n")
        expect(Facter::Core::Execution).to receive(:execute).with('/sbin/auditctl -s', on_fail: nil)
                                                            .and_return(
                                                           [
                                                             'enabled 1',
                                                             'failure 1',
                                                             'pid 1337',
                                                             'rate_limit 0',
                                                             'backlog_limit 64',
                                                             'lost 0',
                                                             'backlog 0',
                                                             'backlog_wait_time 60000',
                                                             'loginuid_immutable 0 unlocked',
                                                           ].join("\n"),
                                                         )
        expect(Facter::Core::Execution).to receive(:execute).with('/bin/ps -e', on_fail: nil)
                                                            .and_return(
                                                           [
                                                             'PID TTY          TIME CMD',
                                                             '  1 ?        00:00:04 systemd',
                                                             '  2 ?        00:00:00 kthreadd',
                                                             '  3 ?        00:00:00 kauditd',
                                                             '  4 ?        00:00:00 auditd',
                                                           ].join("\n"),
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
          'backlog_wait_time'  => 60_000,
          'loginuid_immutable' => '0 unlocked',
        }
      end

      context 'with audit explicitly or implicitly enabled in the kernel' do
        it do
          expect(Facter.fact('simplib__auditd').value).to eq(simplib__auditd_value)
        end
      end
    end

    # simp/auditd's auditd_state fact carries the same auditctl data. When it
    # is present, this fact is built from it without running auditctl or ps,
    # and must come out exactly as if it had gathered the data itself.
    context 'with the auditd_state fact from simp/auditd' do
      let(:auditctl_keys) do
        {
          'failure'            => 1,
          'pid'                => 1337,
          'rate_limit'         => 0,
          'backlog_limit'      => 64,
          'lost'               => 0,
          'backlog'            => 0,
          'backlog_wait_time'  => 60_000,
          'loginuid_immutable' => '0 unlocked',
          'version'            => '1.2.3',
        }
      end

      before(:each) do
        expect(Facter::Core::Execution).not_to receive(:execute)
      end

      it 'matches a properly functioning auditd' do
        allow(Facter).to receive(:value).with('auditd_state').and_return(
          auditctl_keys.merge('enabled' => 1, 'immutable' => false, 'kernel_enforcing' => true, 'enforcing' => true),
        )

        expect(Facter.fact('simplib__auditd').value).to eq(
          auditctl_keys.merge('enabled' => true, 'kernel_enforcing' => true, 'enforcing' => true),
        )
      end

      it 'matches a kernel that is auditing without auditd running' do
        allow(Facter).to receive(:value).with('auditd_state').and_return(
          auditctl_keys.merge('enabled' => 1, 'immutable' => false, 'kernel_enforcing' => true, 'enforcing' => false),
        )

        expect(Facter.fact('simplib__auditd').value).to eq(
          auditctl_keys.merge('enabled' => true, 'kernel_enforcing' => true, 'enforcing' => false),
        )
      end

      it 'matches audit disabled, taking kernel_enforcing from the kernel command line' do
        allow(Facter).to receive(:value).with('auditd_state').and_return(
          auditctl_keys.merge('enabled' => 0, 'immutable' => false, 'kernel_enforcing' => true, 'enforcing' => false),
        )
        expect(Facter).to receive(:value).with('cmdline').and_return({ 'audit' => '1' })

        expect(Facter.fact('simplib__auditd').value).to eq(
          auditctl_keys.merge('enabled' => false, 'kernel_enforcing' => true, 'enforcing' => false),
        )
      end

      # An immutable rule set (enabled 2) has always read as disabled here.
      # auditd_state reports it as enforcing; this fact keeps its old answer.
      it 'keeps the historical answer for an immutable rule set' do
        allow(Facter).to receive(:value).with('auditd_state').and_return(
          auditctl_keys.merge('enabled' => 2, 'immutable' => true, 'kernel_enforcing' => true, 'enforcing' => true),
        )
        expect(Facter).to receive(:value).with('cmdline').and_return({})

        expect(Facter.fact('simplib__auditd').value).to eq(
          auditctl_keys.merge('enabled' => false, 'kernel_enforcing' => false, 'enforcing' => false),
        )
      end

      it 'matches an unreadable status (only the version known)' do
        allow(Facter).to receive(:value).with('auditd_state').and_return(
          { 'version' => '1.2.3', 'immutable' => false, 'kernel_enforcing' => false, 'enforcing' => false },
        )
        expect(Facter).to receive(:value).with('cmdline').and_return({})

        expect(Facter.fact('simplib__auditd').value).to eq(
          { 'version' => '1.2.3', 'enabled' => false, 'kernel_enforcing' => false, 'enforcing' => false },
        )
      end
    end
  end
end
