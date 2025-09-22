require 'spec_helper_acceptance'

test_name 'ipa fact'

def skip_fips?(host)
  return true if fips_enabled(host) && host.host_hash[:roles].include?('no_fips')

  false
end

describe 'ipa fact' do
  let(:manifest) do
    <<~EOS
      $ipa_value = $facts['ipa']
      simplib::inspect('ipa_value', 'oneline_json')
    EOS
  end

  admin_password = '@dm1n=P@ssw0r!'
  ipa_domain = 'test.case'
  ipa_realm = ipa_domain.upcase

  hosts.each do |host|
    next if skip_fips?(host)

    # IPA requires entropy!
    it 'is running haveged or rngd for entropy' do
      apply_manifest_on(host, 'include haveged', accept_all_exit_codes: true)
      apply_manifest_on(host, 'include haveged')
    end

    it 'installs IPA client package' do
      on(host, 'puppet resource package ipa-client ensure=present')
    end

    it 'enables ipv6' do
      on(host, 'puppet resource sysctl net.ipv6.conf.all.disable_ipv6 ensure=present value=0 target=/etc/sysctl.conf')
      on(host, 'puppet resource sysctl net.ipv6.conf.lo.disable_ipv6 ensure=present value=0 target=/etc/sysctl.conf')
    end

    it 'configures the firewall' do
      on(host, 'systemctl is-active firewalld.service && firewall-cmd --add-port={{80,443,389,636,88,464,53}/tcp,{88,464,53,123}/udp} --permanent')
    end

    it 'ensures hostname is set to the FQDN' do
      hostname = pfact_on(host, 'networking.fqdn')
      on(host, "hostnamectl set-hostname #{hostname}")

      # DBus may need to be restarted after updating, and a reboot is the only way
      host.reboot
    end
  end

  hosts_with_role(hosts, 'server').each do |server|
    next if skip_fips?(server)

    context 'when IPA is not installed' do
      it 'ipa fact should be nil' do
        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(%r{Notice: Type => NilClass Content => null})

        expect(pfact_on(server, 'ipa')).to be_nil.or be_empty
      end
    end

    context 'when IPA is installed, but host has not yet joined IPA domain' do
      it 'ipa fact should be nil because /etc/ipa/default.conf does not exist' do
        upgrade_package(server, 'nss')
        install_package(server, 'ipa-server')
        server.reboot # WORKAROUND: https://bugzilla.redhat.com/show_bug.cgi?id=1504688

        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(%r{Notice: Type => NilClass Content => null})

        expect(pfact_on(server, 'ipa')).to be_nil.or be_empty
      end
    end

    context 'when IPA is installed and host has joined IPA domain' do
      let(:ipa_domain) { "#{server.name.downcase}.example.com" }

      it 'ipa fact should contain domain and IPA server' do
        # ipa-server-install installs both the IPA server and client.
        # The fact uses the client env.
        fqdn = pfact_on(server, 'networking.fqdn')

        cmd = [
          'umask 0022 &&',
          'ipa-server-install',
          # IPA realm and domain do not have to match hostname
          "--domain #{ipa_domain}",
          "--realm #{ipa_realm}",
          "--hostname #{fqdn}",
          '--ds-password "d1r3ct0ry=P@ssw0r!"',
          "--admin-password '#{admin_password}'",
          '--unattended',
        ]
        puts "\e[1;34m>>>>> The next step takes a very long time ... Please be patient! \e[0m"
        on(server, cmd.join(' '))
        on(server, 'ipactl status')

        # We only care about this data
        expect(apply_manifest_on(server, manifest).output).to match(%r{Hash Content => \{"})

        results = pfact_on(server, 'ipa')

        expect(results).to be_a(Hash)
        expect(results).not_to be_empty
        expect(results['connected']).to eq true
        expect(results['server']).to eq fqdn
        expect(results['domain']).to eq ipa_domain
        expect(results['realm']).to eq ipa_realm
      end

      it 'ipa fact should have unknown status when connection to IPA server is down' do
        # stop IPA server
        on(server, 'ipactl stop')

        results = pfact_on(server, 'ipa')

        expect(results).to be_a(Hash)
        expect(results).not_to be_empty
        expect(results['connected']).to eq false
      end

      it 'restarts the IPA server for further tests' do
        on(server, 'ipactl start')
      end
    end
  end

  hosts_with_role(hosts, 'client').each do |client|
    next if skip_fips?(client)

    context 'as an IPA client' do
      context 'prior to registration' do
        it 'does not have an IPA fact' do
          expect(pfact_on(client, 'ipa')).to be_nil.or be_empty
        end
      end

      context 'after registration' do
        let(:ipa_server) do
          pfact_on(hosts_with_role(hosts, 'server').first, 'networking.fqdn')
        end

        it 'registers with the IPA server' do
          os = fact_on(client, 'os')
          ipa_command = [
            # Unattended installation
            'ipa-client-install -U',
            # IPA directory domain
            "--domain=#{ipa_domain}",
            # IPA server to use
            "--server=#{ipa_server}",
            # Only point at this server and don't use SRV
            '--fixed-primary',
            # IPA krb5 realm
            "--realm=#{ipa_realm}",
            # Krb5 principal name to use
            '--principal=admin',
            # Admin password
            "--password='#{admin_password}'",
          ].join(' ')
          # Force ntpd support on EL7
          ipa_command += ' --force-ntpd' if os.dig('release', 'major') == '7'

          on(client, ipa_command)
        end

        it 'has the IPA fact populated' do
          results = pfact_on(client, 'ipa')

          expect(results).to be_a(Hash)
          expect(results).not_to be_empty
          expect(results['connected']).to eq true
          expect(results['server']).to eq ipa_server
          expect(results['domain']).to eq ipa_domain
          expect(results['realm']).to eq ipa_realm
        end

        it 'ipa fact should have unknown status when connection to IPA server is down' do
          # stop IPA server
          hosts_with_role(hosts, 'server').each do |server|
            on(server, 'ipactl stop')
          end

          results = pfact_on(client, 'ipa')

          expect(results).to be_a(Hash)
          expect(results).not_to be_empty
          expect(results['connected']).to eq false
        end

        it 'restarts the IPA server for further tests' do
          hosts_with_role(hosts, 'server').each do |server|
            on(server, 'ipactl start')
          end
        end
      end
    end
  end
end
