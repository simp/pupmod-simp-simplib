# frozen_string_literal: true

require 'spec_helper'

describe 'grub_version' do
  before :each do
    Facter.clear
  end

  context 'when using Legacy GRUB' do
    it do
      Facter::Util::Resolution.stubs(:which).with('grub').returns(true)
      Facter::Util::Resolution.stubs(:exec).with('grub --version').returns("grub (GNU GRUB 0.97)\n")

      expect(Facter.fact('grub_version').value).to eq('0.97')
    end
  end

  context 'when using GRUB2' do
    it do
      Facter::Util::Resolution.stubs(:which).with('grub').returns(false)
      Facter::Util::Resolution.stubs(:which).with('grub2-mkconfig').returns(true)
      Facter::Util::Resolution.stubs(:exec).with('grub2-mkconfig --version').returns("grub2-mkconfig (GRUB) 2.02~beta2\n")

      expect(Facter.fact('grub_version').value).to eq('2.02~beta2')
    end
  end
end
