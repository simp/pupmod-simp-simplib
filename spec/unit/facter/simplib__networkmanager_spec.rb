require 'spec_helper'

describe 'simplib__networkmanager' do
  before :each do
    Facter.clear
    # mock out Facter method called when evaluating confine for :kernel
    allow(Facter::Resolvers::Uname).to receive(:resolve).with(any_args).and_return('Linux')

    allow(Facter::Core::Execution).to receive(:which).and_call_original
    allow(Facter::Core::Execution).to receive(:which).with('nmcli').and_return('/usr/sbin/nmcli')

    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t -m multiline general status').and_return(general_status)
    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t general hostname').and_return(general_hostname)
    allow(Puppet::Util::Execution).to receive(:execute).with('/usr/sbin/nmcli -t connection show').and_return(connections)
  end

  context 'nmcli fails' do
    let(:general_status) { Puppet::Util::Execution::ProcessOutput.new('', 1) }
    let(:general_hostname) { Puppet::Util::Execution::ProcessOutput.new('', 1) }
    let(:connections) { Puppet::Util::Execution::ProcessOutput.new('', 1) }

    it 'returns "enabled" = false' do
      # allow_any_instance_of(Process::Status).to receive(:success?).and_return(false)

      expect(Facter.fact('simplib__networkmanager').value).to eq({ 'enabled' => false })
    end
  end

  context 'nmcli succeeds' do
    let(:general_status) do
      output = <<~EOM
        STATE:connected
        CONNECTIVITY:full
        WIFI-HW:enabled
        WIFI:enabled
        WWAN-HW:enabled
        WWAN:enabled
        EOM
      Puppet::Util::Execution::ProcessOutput.new(output, 0)
    end

    let(:general_hostname) { Puppet::Util::Execution::ProcessOutput.new("foo.bar.baz\n", 0) }

    let(:expected_general) do
      {
        'hostname' => 'foo.bar.baz',
        'status' => {
          'STATE' => 'connected',
          'CONNECTIVITY' => 'full',
          'WIFI-HW' => 'enabled',
          'WIFI' => 'enabled',
          'WWAN-HW' => 'enabled',
          'WWAN' => 'enabled',
        },
      }
    end

    context 'when every connection has a device' do
      let(:connections) do
        output = <<~EOM
          Eth Dev:b961cb37-ae05-4c67-98b0-432465fe03c2:802-3-ethernet:eth0
          Bridge Dev:0c190f3f-262b-4585-a7de-2a146896ea86:bridge:virbr0
          EOM
        Puppet::Util::Execution::ProcessOutput.new(output, 0)
      end

      let(:expected) do
        {
          'enabled' => true,
          'general' => expected_general,
          'connection' => {
            'b961cb37-ae05-4c67-98b0-432465fe03c2' => {
              'device' => 'eth0',
              'uuid' => 'b961cb37-ae05-4c67-98b0-432465fe03c2',
              'type' => '802-3-ethernet',
              'name' => 'Eth Dev',
            },
            '0c190f3f-262b-4585-a7de-2a146896ea86' => {
              'device' => 'virbr0',
              'uuid' => '0c190f3f-262b-4585-a7de-2a146896ea86',
              'type' => 'bridge',
              'name' => 'Bridge Dev',
            },
          },
        }
      end

      it 'is enabled and keys the connections by UUID' do
        expect(Facter.fact('simplib__networkmanager').value).to eq(expected)
      end
    end

    # https://github.com/simp/pupmod-simp-simplib/issues/289
    context 'when a connection is not attached to a device' do
      # 'ens160' is a defined but inactive connection, so nmcli reports an
      # empty DEVICE field for it. Note that its *name* matches the device of
      # the active 'System ens160' connection.
      let(:connections) do
        output = <<~EOM
          System ens160:ea74cf24-c2a2-ecee-3747-a2d76d46f93b:802-3-ethernet:ens160
          lo:04577901-581b-4cac-bb04-f015fe36274d:loopback:lo
          ens160:5780e094-7abe-419a-9c3e-de716150898d:802-3-ethernet:
          EOM
        Puppet::Util::Execution::ProcessOutput.new(output, 0)
      end

      let(:expected) do
        {
          'enabled' => true,
          'general' => expected_general,
          'connection' => {
            'ea74cf24-c2a2-ecee-3747-a2d76d46f93b' => {
              'device' => 'ens160',
              'uuid' => 'ea74cf24-c2a2-ecee-3747-a2d76d46f93b',
              'type' => '802-3-ethernet',
              'name' => 'System ens160',
            },
            '04577901-581b-4cac-bb04-f015fe36274d' => {
              'device' => 'lo',
              'uuid' => '04577901-581b-4cac-bb04-f015fe36274d',
              'type' => 'loopback',
              'name' => 'lo',
            },
            '5780e094-7abe-419a-9c3e-de716150898d' => {
              'device' => nil,
              'uuid' => '5780e094-7abe-419a-9c3e-de716150898d',
              'type' => '802-3-ethernet',
              'name' => 'ens160',
            },
          },
        }
      end

      it 'reports every connection, including the one without a device' do
        expect(Facter.fact('simplib__networkmanager').value).to eq(expected)
      end

      it 'does not drop the connection whose device matches another connection name' do
        # Keying on the device silently overwrote 'System ens160' with the
        # deviceless 'ens160' connection
        names = Facter.fact('simplib__networkmanager').value['connection'].values.map { |conn| conn['name'] }

        expect(names).to contain_exactly('System ens160', 'lo', 'ens160')
      end

      it 'does not create an empty connection key' do
        expect(Facter.fact('simplib__networkmanager').value['connection'].keys).to all(satisfy { |key| !key.nil? && !key.empty? })
      end
    end

    # https://github.com/simp/pupmod-simp-simplib/issues/367
    #
    # In terse tabular mode nmcli escapes ':' as '\:' and '\' as '\\' inside
    # values. These lines are verbatim output from NetworkManager 1.56.1 for
    # connections named 'simplib:test:colon' and 'simplib\back'.
    context 'when a connection name contains escaped characters' do
      let(:connections) do
        output = <<~EOM
          simplib\\:test\\:colon:fc3e33e0-7ae1-4a45-b136-49433f4b0c57:802-3-ethernet:
          simplib\\\\back:29a737eb-ade9-475b-81cb-0ca3f46f8752:802-3-ethernet:eth0
          EOM
        Puppet::Util::Execution::ProcessOutput.new(output, 0)
      end

      it 'unescapes a colon in the name without shifting the other fields' do
        connection = Facter.fact('simplib__networkmanager').value['connection']['fc3e33e0-7ae1-4a45-b136-49433f4b0c57']

        expect(connection).to eq(
          'device' => nil,
          'uuid' => 'fc3e33e0-7ae1-4a45-b136-49433f4b0c57',
          'type' => '802-3-ethernet',
          'name' => 'simplib:test:colon',
        )
      end

      # The separator after 'simplib\\back' follows a backslash, so a naive
      # lookbehind would treat it as escaped and swallow the whole line
      it 'unescapes a backslash at the end of a value and still splits on the next colon' do
        connection = Facter.fact('simplib__networkmanager').value['connection']['29a737eb-ade9-475b-81cb-0ca3f46f8752']

        expect(connection).to eq(
          'device' => 'eth0',
          'uuid' => '29a737eb-ade9-475b-81cb-0ca3f46f8752',
          'type' => '802-3-ethernet',
          'name' => 'simplib\\back',
        )
      end

      it 'keys both connections by their real UUID' do
        expect(Facter.fact('simplib__networkmanager').value['connection'].keys).to contain_exactly(
          'fc3e33e0-7ae1-4a45-b136-49433f4b0c57',
          '29a737eb-ade9-475b-81cb-0ca3f46f8752',
        )
      end
    end

    # NetworkManager does not enforce unique connection names; nmcli itself
    # disambiguates with the UUID, which is why the fact keys on it
    context 'when two connections share a name' do
      let(:connections) do
        output = <<~EOM
          Wired connection 1:5b6d3d0e-8d55-4c0e-9b8c-6bb25f6b5dc9:802-3-ethernet:eth0
          Wired connection 1:8e1d8a5b-2fd4-4a29-9e5f-1b2c3d4e5f60:802-3-ethernet:
          EOM
        Puppet::Util::Execution::ProcessOutput.new(output, 0)
      end

      it 'reports both connections' do
        connection = Facter.fact('simplib__networkmanager').value['connection']

        expect(connection.keys).to contain_exactly(
          '5b6d3d0e-8d55-4c0e-9b8c-6bb25f6b5dc9',
          '8e1d8a5b-2fd4-4a29-9e5f-1b2c3d4e5f60',
        )
        expect(connection['5b6d3d0e-8d55-4c0e-9b8c-6bb25f6b5dc9']['device']).to eq('eth0')
        expect(connection['8e1d8a5b-2fd4-4a29-9e5f-1b2c3d4e5f60']['device']).to be_nil
        expect(connection.values.map { |conn| conn['name'] }).to eq(['Wired connection 1', 'Wired connection 1'])
      end
    end
  end
end
