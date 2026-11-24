# frozen_string_literal: true

require 'spec_helper'

describe 'runlevel' do
  before :each do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
  end

  context 'when runlevel binary is available' do
    it 'returns the current runlevel' do
      expect(Facter::Core::Execution).to receive(:which).with('runlevel').and_return('/sbin/runlevel')
      expect(Facter::Core::Execution).to receive(:exec).with('/sbin/runlevel').and_return('N 3')

      expect(Facter.fact('runlevel').value).to eq('3')
    end
  end

  context 'when runlevel binary is not available' do
    before :each do
      expect(Facter::Core::Execution).to receive(:which).with('runlevel').and_return(nil)
    end

    context 'when systemctl is available' do
      before :each do
        expect(Facter::Core::Execution).to receive(:which).with('systemctl').and_return('/usr/bin/systemctl')
      end

      {
        'poweroff.target'   => '0',
        'rescue.target'     => '1',
        'multi-user.target' => '3',
        'graphical.target'  => '5',
        'reboot.target'     => '6',
      }.each do |target, expected_runlevel|
        context "when the default target is #{target}" do
          it "returns runlevel #{expected_runlevel}" do
            expect(Facter::Core::Execution).to receive(:exec).with('systemctl get-default').and_return("#{target}\n")

            expect(Facter.fact('runlevel').value).to eq(expected_runlevel)
          end
        end
      end

      context 'when the default target is an unmapped target' do
        it 'returns nil' do
          expect(Facter::Core::Execution).to receive(:exec).with('systemctl get-default').and_return("emergency.target\n")

          expect(Facter.fact('runlevel').value).to be nil
        end
      end
    end

    context 'when systemctl is not available' do
      it 'returns nil' do
        expect(Facter::Core::Execution).to receive(:which).with('systemctl').and_return(nil)

        expect(Facter.fact('runlevel').value).to be nil
      end
    end
  end
end
