require 'spec_helper'

describe 'simplib__networkmanager' do

  before :each do
    Facter.clear
    # mock out Facter method called when evaluating confine for :kernel
    # Facter 4
    if defined?(Facter::Resolvers::Uname)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(any_args).and_return('Linux')
    else
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
    end

    allow(Facter::Util::Resolution).to receive(:which).and_call_original
    allow(Facter::Util::Resolution).to receive(:which).with('nmcli').and_return('/usr/sbin/nmcli')

    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t -m multiline general status').and_return(general_status)
    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t general hostname').and_return(general_hostname)
    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t connection show').and_return(connections)
  end

  context 'nmcli fails' do
    let(:general_status){ Puppet::Util::Execution::ProcessOutput.new('', 1) }
    let(:general_hostname){ Puppet::Util::Execution::ProcessOutput.new('', 1) }
    let(:connections){ Puppet::Util::Execution::ProcessOutput.new('', 1) }

    it 'returns "enabled" = false' do
      # allow_any_instance_of(Process::Status).to receive(:success?).and_return(false)

      expect(Facter.fact('simplib__networkmanager').value).to eq({'enabled' => false})
    end
  end

  context 'nmcli succeeds' do
    let(:general_status){
      output = <<~EOM
        STATE:connected
        CONNECTIVITY:full
        WIFI-HW:enabled
        WIFI:enabled
        WWAN-HW:enabled
        WWAN:enabled
        EOM
      Puppet::Util::Execution::ProcessOutput.new(output, 0)
    }

    let(:general_hostname){ Puppet::Util::Execution::ProcessOutput.new("foo.bar.baz\n", 0) }

    let(:connections){
      output = <<~EOM
        Eth Dev:b961cb37-ae05-4c67-98b0-432465fe03c2:802-3-ethernet:eth0
        Bridge Dev:0c190f3f-262b-4585-a7de-2a146896ea86:bridge:virbr0
        EOM
      Puppet::Util::Execution::ProcessOutput.new(output, 0)
    }

    let(:expected){{
      'enabled'    => true,
      'general'    => {
        'hostname' => general_hostname.strip,
        'status'   => {
          'STATE'        => 'connected',
          'CONNECTIVITY' => 'full',
          'WIFI-HW'      => 'enabled',
          'WIFI'         => 'enabled',
          'WWAN-HW'      => 'enabled',
          'WWAN'         => 'enabled'
        },
      },
      'connection' => {
        'eth0'   => {
          'uuid' => 'b961cb37-ae05-4c67-98b0-432465fe03c2',
          'type' => '802-3-ethernet',
          'name' => 'Eth Dev'
        },
        'virbr0' => {
          'uuid' => '0c190f3f-262b-4585-a7de-2a146896ea86',
          'type' => 'bridge',
          'name' => 'Bridge Dev'
        }
      }
    }}

    it 'is enabled' do
      expect(Facter.fact('simplib__networkmanager').value).to eq(expected)
    end
  end
end
