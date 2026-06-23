require 'spec_helper'

describe 'shmall' do
  let(:path) { '/proc/sys/kernel/shmall' }

  before :each do
    Facter.clear
    allow(File).to receive(:read).with(any_args).and_call_original
  end

  context 'when kernel.shmall is available' do
    it 'returns the value as a stripped String' do
      expect(File).to receive(:read).with(path).and_return("18446744073692774399\n")
      expect(Facter.fact(:shmall).value).to eq('18446744073692774399')
    end
  end

  context 'when the sysctl path is unavailable' do
    it 'is nil rather than raising' do
      expect(File).to receive(:read).with(path).and_raise(Errno::ENOENT)
      expect(Facter.fact(:shmall).value).to be_nil
    end
  end
end
