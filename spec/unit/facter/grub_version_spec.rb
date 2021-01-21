# frozen_string_literal: true

require 'spec_helper'

describe 'grub_version' do
  before :each do
    Facter.clear
  end

  context 'when using Legacy GRUB' do
    it do
      expect(Facter::Util::Resolution).to receive(:which).with('grub').and_return(true)
      expect(Facter::Util::Resolution).to receive(:exec).with('grub --version').and_return("grub (GNU GRUB 0.97)\n")

      expect(Facter.fact('grub_version').value).to eq('0.97')
    end
  end

  context 'when using GRUB2' do
    it do
      expect(Facter::Util::Resolution).to receive(:which).with('grub').and_return(false)
      expect(Facter::Util::Resolution).to receive(:which).with('grub2-mkconfig').and_return(true)
      expect(Facter::Util::Resolution).to receive(:exec).with('grub2-mkconfig --version').and_return("grub2-mkconfig (GRUB) 2.02~beta2\n")

      expect(Facter.fact('grub_version').value).to eq('2.02~beta2')
    end
  end
end
