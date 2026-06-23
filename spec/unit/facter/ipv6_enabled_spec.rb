require 'spec_helper'

describe 'ipv6_enabled' do
  let(:path) { '/proc/sys/net/ipv6/conf/all/disable_ipv6' }

  before :each do
    Facter.clear
    allow(File).to receive(:read).with(any_args).and_call_original
  end

  context 'when IPv6 is enabled' do
    it 'is true (disable_ipv6 == 0)' do
      expect(File).to receive(:read).with(path).and_return("0\n")
      expect(Facter.fact(:ipv6_enabled).value).to be true
    end
  end

  context 'when IPv6 is disabled' do
    it 'is false (disable_ipv6 == 1)' do
      expect(File).to receive(:read).with(path).and_return("1\n")
      expect(Facter.fact(:ipv6_enabled).value).to be false
    end
  end

  context 'when the sysctl path is unavailable' do
    it 'is false rather than raising' do
      expect(File).to receive(:read).with(path).and_raise(Errno::ENOENT)
      expect(Facter.fact(:ipv6_enabled).value).to be false
    end
  end
end
