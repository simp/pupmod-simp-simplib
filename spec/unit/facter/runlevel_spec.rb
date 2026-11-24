# frozen_string_literal: true

require 'spec_helper'

describe 'runlevel' do
  let(:target_list) do
    <<~TARGETS
      graphical.target   loaded active active Graphical Interface
      multi-user.target  loaded active active Multi-User System
      basic.target       loaded active active Basic System
    TARGETS
  end

  before :each do
    Facter.clear

    allow(Facter).to receive(:value).and_call_original
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
    allow(Facter::Core::Execution).to receive(:which).and_call_original
    allow(Facter::Core::Execution).to receive(:execute).and_call_original

    allow(Facter::Core::Execution).to receive(:which).with('runlevel').and_return(nil)
    allow(Facter::Core::Execution).to receive(:which).with('systemctl').and_return('/usr/bin/systemctl')
  end

  context 'when the runlevel binary is available' do
    before :each do
      allow(Facter::Core::Execution).to receive(:which).with('runlevel').and_return('/sbin/runlevel')
    end

    it 'returns the current runlevel from that binary' do
      allow(Facter::Core::Execution).to receive(:execute).with('/sbin/runlevel', on_fail: nil).and_return("N 3\n")

      expect(Facter.fact('runlevel').value).to eq('3')
    end

    it 'does not query systemd targets' do
      allow(Facter::Core::Execution).to receive(:execute).with('/sbin/runlevel', on_fail: nil).and_return("N 3\n")

      expect(Facter::Core::Execution).not_to receive(:execute).with(a_string_matching('list-units'), anything)

      expect(Facter.fact('runlevel').value).to eq('3')
    end
  end

  context 'when the runlevel binary is absent' do
    {
      'graphical and multi-user active' => ["graphical.target\nmulti-user.target\n", '5'],
      'only multi-user active'         => ["multi-user.target\nbasic.target\n", '3'],
      'only rescue active'             => ["rescue.target\n", '1'],
      'reboot active'                  => ["reboot.target\n", '6'],
      'poweroff active'                => ["poweroff.target\n", '0'],
      'no mapped target active'        => ["basic.target\n", nil],
      'empty output'                   => ['', nil],
      'command failure'                => [nil, nil],
      'description names another target' => ["multi-user.target loaded active active Multi-User\nfoo.target loaded active active Runs before reboot.target\n", '3'],
    }.each do |description, (output, expected)|
      it "returns #{expected.inspect} when #{description}" do
        allow(Facter::Core::Execution).to receive(:execute).with(a_string_matching('list-units'), on_fail: nil).and_return(output)

        expect(Facter.fact('runlevel').value).to eq(expected)
      end
    end

    it 'reports the running target rather than the default boot target' do
      # A system booted into graphical.target whose default was later changed
      # to multi-user.target still runs at level 5.
      allow(Facter::Core::Execution).to receive(:execute).with(a_string_matching('list-units'), on_fail: nil).and_return(target_list)

      expect(Facter::Core::Execution).not_to receive(:execute).with('systemctl get-default')

      expect(Facter.fact('runlevel').value).to eq('5')
    end
  end

  context 'when neither runlevel nor systemctl is available' do
    before :each do
      allow(Facter::Core::Execution).to receive(:which).with('systemctl').and_return(nil)
    end

    it 'returns nil' do
      expect(Facter.fact('runlevel').value).to be_nil
    end
  end
end
