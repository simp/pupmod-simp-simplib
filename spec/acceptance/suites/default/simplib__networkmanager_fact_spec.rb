require 'spec_helper_acceptance'

test_name 'simplib__networkmanager fact'

describe 'simplib__networkmanager fact' do
  # Somewhere early in the PATH, so that it takes precedence over a real
  # `nmcli` if NetworkManager happens to be installed. Packaged NetworkManager
  # installs `nmcli` in /usr/bin, so nothing should own this path, but move
  # anything that does out of the way rather than clobbering it.
  stub_nmcli = '/usr/local/sbin/nmcli'
  stub_backup = "#{stub_nmcli}.simplib-spec-backup"

  # `nmcli` output from https://github.com/simp/pupmod-simp-simplib/issues/289
  #
  # The 'ens160' connection is defined but not active, so NetworkManager
  # reports an empty DEVICE field for it. Note that its *name* matches the
  # device of the (active) 'System ens160' connection.
  #
  # The last line covers https://github.com/simp/pupmod-simp-simplib/issues/367:
  # nmcli escapes ':' as '\:' inside a value, so 'simplib:test:colon' arrives
  # with its colons escaped.
  stub_connections = [
    'System ens160:ea74cf24-c2a2-ecee-3747-a2d76d46f93b:802-3-ethernet:ens160',
    'lo:04577901-581b-4cac-bb04-f015fe36274d:loopback:lo',
    'ens160:5780e094-7abe-419a-9c3e-de716150898d:802-3-ethernet:',
    'simplib\:test\:colon:fc3e33e0-7ae1-4a45-b136-49433f4b0c57:802-3-ethernet:',
  ]

  stub_nmcli_content = <<~STUB
    #!/bin/bash
    # Test stub installed by #{__FILE__}
    case "$*" in
      *'general status'*)
        printf 'STATE:connected\\nCONNECTIVITY:full\\nWIFI-HW:enabled\\nWIFI:enabled\\nWWAN-HW:enabled\\nWWAN:enabled\\n'
        ;;
      *'general hostname'*)
        echo 'nmcli-stub.test.local'
        ;;
      *'connection show'*)
        printf '%s\\n' #{stub_connections.map { |conn| "'#{conn}'" }.join(' ')}
        ;;
      *)
        exit 1
        ;;
    esac
  STUB

  # A connection that is never activated, so that NetworkManager reports no
  # device for it
  live_connection = 'simplib-test-nodev'

  # Connection names that nmcli has to escape on the way out (#367)
  live_colon_connection = 'simplib-test:colon'
  live_backslash_connection = 'simplib-test\\backslash'

  hosts.each do |host|
    # Set by the 'running NetworkManager' context, which can only run on hosts
    # where NetworkManager is actually usable (not in a container)
    networkmanager_running = false
    live_connection_uuid = nil
    live_colon_uuid = nil
    live_backslash_uuid = nil

    context "on #{host}" do
      context 'with connections that have no device' do
        before(:all) do
          on(host, "mkdir -p #{File.dirname(stub_nmcli)}")
          on(host, "if [ -e #{stub_nmcli} ] || [ -L #{stub_nmcli} ]; then mv -f #{stub_nmcli} #{stub_backup}; fi")
          create_remote_file(host, stub_nmcli, stub_nmcli_content)
          on(host, "chmod 755 #{stub_nmcli}")
        end

        after(:all) do
          on(host, "rm -f #{stub_nmcli}")
          on(host, "if [ -e #{stub_backup} ] || [ -L #{stub_backup} ]; then mv -f #{stub_backup} #{stub_nmcli}; fi")
        end

        it 'finds the stubbed nmcli first' do
          expect(on(host, 'command -v nmcli').stdout.strip).to eq(stub_nmcli)
        end

        it 'reports NetworkManager as enabled' do
          expect(pfact_on(host, 'simplib__networkmanager')['enabled']).to be true
        end

        it 'keys every connection by UUID' do
          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection.keys).to contain_exactly(
            'ea74cf24-c2a2-ecee-3747-a2d76d46f93b',
            '04577901-581b-4cac-bb04-f015fe36274d',
            '5780e094-7abe-419a-9c3e-de716150898d',
            'fc3e33e0-7ae1-4a45-b136-49433f4b0c57',
          )
        end

        it 'does not create an empty connection key' do
          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection.keys).to all(satisfy { |key| !key.nil? && !key.empty? })
        end

        it 'reports the device of each connection' do
          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection['ea74cf24-c2a2-ecee-3747-a2d76d46f93b']).to eq(
            'device' => 'ens160',
            'uuid' => 'ea74cf24-c2a2-ecee-3747-a2d76d46f93b',
            'type' => '802-3-ethernet',
            'name' => 'System ens160',
          )
          expect(connection['04577901-581b-4cac-bb04-f015fe36274d']).to include('device' => 'lo', 'name' => 'lo')

          # The connection without a device is still reported, with no device
          expect(connection['5780e094-7abe-419a-9c3e-de716150898d']).to include(
            'type' => '802-3-ethernet',
            'name' => 'ens160',
          )
          expect(connection['5780e094-7abe-419a-9c3e-de716150898d']['device']).to be_nil
        end

        it 'unescapes a connection name that contains a colon' do
          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection['fc3e33e0-7ae1-4a45-b136-49433f4b0c57']).to include('name' => 'simplib:test:colon')
        end
      end

      context 'with a running NetworkManager' do
        before(:all) do
          networkmanager_running = on(
            host,
            'nmcli general status',
            accept_all_exit_codes: true,
          ).exit_code.zero?

          next unless networkmanager_running

          # `ifname` names an interface that does not exist, so the connection
          # can never be activated and NetworkManager reports no device for it
          on(host, "nmcli connection add type ethernet con-name #{live_connection} ifname simplib-tst0 autoconnect no")
          live_connection_uuid = on(host, "nmcli -g connection.uuid connection show #{live_connection}").stdout.strip

          # NetworkManager allows ':' and '\\' in a connection name and escapes
          # them in terse output, so make sure the fact can read them back
          [live_colon_connection, live_backslash_connection].each do |name|
            on(host, "nmcli connection add type ethernet con-name '#{name}' ifname simplib-tst1 autoconnect no")
          end

          live_colon_uuid = on(host, "nmcli -g connection.uuid connection show '#{live_colon_connection}'").stdout.strip
          live_backslash_uuid = on(host, "nmcli -g connection.uuid connection show '#{live_backslash_connection}'").stdout.strip
        end

        after(:all) do
          next unless networkmanager_running

          [live_connection, live_colon_connection, live_backslash_connection].each do |name|
            on(host, "nmcli connection delete '#{name}'", accept_all_exit_codes: true)
          end
        end

        it 'reports a connection that is not attached to a device' do
          skip('NetworkManager is not running on this host') unless networkmanager_running

          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection.keys).to include(live_connection_uuid)
          expect(connection[live_connection_uuid]['name']).to eq(live_connection)
          expect(connection[live_connection_uuid]['type']).to eq('802-3-ethernet')
          expect(connection[live_connection_uuid]['device']).to be_nil
          expect(connection.keys).to all(satisfy { |key| !key.nil? && !key.empty? })
        end

        it 'unescapes connection names containing a colon or a backslash' do
          skip('NetworkManager is not running on this host') unless networkmanager_running

          connection = pfact_on(host, 'simplib__networkmanager')['connection']

          expect(connection[live_colon_uuid]['name']).to eq(live_colon_connection)
          expect(connection[live_backslash_uuid]['name']).to eq(live_backslash_connection)
        end

        it 'reports every connection that nmcli knows about' do
          skip('NetworkManager is not running on this host') unless networkmanager_running

          connection = pfact_on(host, 'simplib__networkmanager')['connection']
          expected = on(host, 'nmcli -g UUID connection show').stdout.lines.map(&:strip).reject(&:empty?)

          expect(connection.keys).to contain_exactly(*expected)
        end
      end
    end
  end
end
