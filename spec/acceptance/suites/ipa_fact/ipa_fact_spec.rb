require 'spec_helper_acceptance'

test_name 'ipa fact'

describe 'ipa fact' do
  let (:manifest) {
    <<-EOS
      $ipa_value = $facts['ipa']
      simplib::inspect('ipa_value', 'oneline_json')
    EOS
  }

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    # Skip EL6 if FIPS is enabled
    # IPA server on EL6 doens't support EL6, only EL7.4+
    # See https://www.freeipa.org/page/Releases/4.5.0#FIPS_140-2_Support
    next if (ENV['BEAKER_fips'] && server.platform == 'el-6-x86_64')

    context 'when IPA is not installed' do
      it 'ipa fact should be nil' do
        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)
        results = on(server, 'puppet facts')
        expect(results.output).to_not match(/"ipa": {/)
      end
    end

    context 'when IPA is installed, but host has not yet joined IPA domain' do
      it 'ipa fact should be nil because /etc/ipa/default.conf does not exist' do
        install_package(server, 'ipa-server')

        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)
        results = on(server, 'puppet facts')
        expect(results.output).to_not match(/"ipa": {/)
      end
    end

    context 'when IPA is installed and host has joined IPA domain' do
      let(:ipa_domain) { "#{server.name.downcase}.example.com" }
      it 'ipa fact should contain domain and IPA server' do
        # IPA requires entropy, so use haveged service
        on(server, 'puppet resource package epel-release ensure=present')
        on(server, 'puppet resource package haveged ensure=present')
        on(server, 'puppet resource service haveged ensure=running enable=true')

        # ipa-server-install installs both the IPA server and client.
        # The fact uses the client env.
        fqdn = on(server,'facter fqdn').output.strip
        cmd = [
          'ipa-server-install',
          # IPA realm and domain do not have to match hostname
          "--domain #{server.name.downcase}.example.com",
          "--realm #{server.name.upcase}.EXAMPLE.COM",
          "--hostname #{fqdn}",
          '--ds-password d1r3ct0ry=P@ssw0r!',
          '--admin-password @dm1n=P@ssw0r!',
          '--unattended'
        ]
        puts "\e[1;34m>>>>> The next step takes a very long time ... Please be patient! \e[0m"
        on(server, cmd.join(' '))
        on(server, 'ipactl status')

        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => Hash Content => {"default_domain":"#{ipa_domain}","default_server":"#{fqdn}","status":"joined","domain":"#{ipa_domain}","server":"#{fqdn}"}/)
        results = on(server, 'puppet facts')
        expect(results.output).to match(/"ipa": {/)
      end

      it 'ipa fact should have unknown status when connection to IPA server is down' do
        # stop IPA server
        on(server, 'ipactl stop')

        fqdn = on(server,'facter fqdn').output.strip
        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => Hash Content => {"default_domain":"#{ipa_domain}","default_server":"#{fqdn}","status":"unknown","domain":"","server":""}/)
        results = on(server, 'puppet facts')
        expect(results.output).to match(/"ipa": {/)
      end
    end
  end
end
