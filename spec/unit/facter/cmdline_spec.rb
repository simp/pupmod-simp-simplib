require 'spec_helper'

describe 'cmdline' do
  before :each do
    Facter.clear
    allow(File).to receive(:read).with(any_args).and_call_original
  end

  let(:unique_line) {
    'root=/dev/mapper/VolGroup00-RootVol ro console=ttyS1,57600 rd.lvm.lv=VolGroup00/RootVol rhgb quiet rd.shell=0'
  }
  let(:dup_line) {
    'root=/dev/mapper/VolGroup00-RootVol ro console=ttyS1,57600 rd.lvm.lv=VolGroup00/RootVol rd.lvm.lv=VolGroup00/SwapVol rhgb quiet rd.shell=0'
  }

  context '/proc/cmdline exists' do
    it 'and has no duplicate entries' do
      expect(File).to receive(:read).with('/proc/cmdline').and_return(unique_line)
      expect(Facter.fact(:cmdline).value).to eq({
        'root'      => '/dev/mapper/VolGroup00-RootVol',
        'ro'        => nil,
        'console'   => 'ttyS1,57600',
        'rd.lvm.lv' => 'VolGroup00/RootVol',
        'rhgb'      => nil,
        'quiet'     => nil,
        'rd.shell'  => '0'
      })
    end

    it 'and has duplicate entries' do
      expect(File).to receive(:read).with('/proc/cmdline').and_return(dup_line)
      expect(Facter.fact(:cmdline).value).to eq({
        'root'      => '/dev/mapper/VolGroup00-RootVol',
        'ro'        => nil,
        'console'   => 'ttyS1,57600',
        'rd.lvm.lv' => [
          'VolGroup00/RootVol',
          'VolGroup00/SwapVol'
        ],
        'rhgb'      => nil,
        'quiet'     => nil,
        'rd.shell'  => '0'
      })
    end
  end

  context '/proc/cmdline does not exist' do
    it 'returns nil' do
      expect(Facter::Util::Resolution).to receive(:which).with('ip').and_return(nil)
      expect(Facter.fact(:defaultgateway).value).to eq('unknown')
    end
  end
end
