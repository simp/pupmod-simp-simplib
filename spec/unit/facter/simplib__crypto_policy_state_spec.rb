# frozen_string_literal: true

require 'spec_helper'

describe 'simplib__crypto_policy_state' do
  before :each do
    Facter.clear

    # Mock out Facter method called when evaluating confine for :kernel
    allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')

    # Ensure that something sane is returned when finding the command
    allow(Facter::Util::Resolution).to receive(:which).with('update-crypto-policies').and_return('update-crypto-policies')
  end

  context 'with a functional update-crypto-policies command' do
    before :each do
      allow(Facter::Core::Execution).to receive(:execute).with('update-crypto-policies --no-reload --show', on_fail: false).and_return("DEFAULT\n")

      allow(Dir).to receive(:glob).with(['/usr/share/crypto-policies/policies/*.pol', '/etc/crypto-policies/policies/*.pol']).and_return(
        [
          '/usr/share/crypto-policies/policies/DEFAULT.pol',
          '/usr/share/crypto-policies/policies/LEGACY.pol',
          '/etc/crypto-policies/policies/DEFAULT.pol',
          '/etc/crypto-policies/policies/CUSTOM.pol',
        ],
      )
    end

    context 'when applied' do
      before :each do
        allow(Facter::Core::Execution).to receive(:execute).with('update-crypto-policies --no-reload --is-applied', on_fail: false).and_return("The configured policy is applied\n")
      end

      it do
        expect(Facter.fact('simplib__crypto_policy_state').value).to include(
          {
            'global_policy' => 'DEFAULT',
            'global_policy_applied' => true,
            'global_policies_available' => ['DEFAULT', 'LEGACY', 'CUSTOM'],
          },
        )
      end
    end

    context 'when not applied' do
      before :each do
        allow(Facter::Core::Execution).to receive(:execute).with('update-crypto-policies --no-reload --is-applied', on_fail: false).and_return("The configured policy is NOT applied\n")
      end

      it do
        expect(Facter.fact('simplib__crypto_policy_state').value).to include(
          {
            'global_policy' => 'DEFAULT',
            'global_policy_applied' => false,
            'global_policies_available' => ['DEFAULT', 'LEGACY', 'CUSTOM'],
          },
        )
      end
    end
  end

  context 'with a non-functional update-crypto-policies command' do
    it 'returns a nil value' do
      allow(Facter::Core::Execution).to receive(:execute).with('update-crypto-policies --no-reload --show', on_fail: false).and_return(false)

      expect(Facter.fact('simplib__crypto_policy_state').value).to be_nil
    end
  end
end
