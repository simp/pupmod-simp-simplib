require 'spec_helper'

describe "custom fact ipa" do
  let (:default_conf) {
    [
      'host = client.example.com',
      'basedn = dc=example,dc=com',
      'realm = EXAMPLE.COM',
      # In next 2 config lines, artificially prepend domain and IPA
      # server with 'default.' so we can validate parsing.
      'domain = default.example.com',
      'xmlrpc_uri = https://default.ipaserver.example.com/ipa/xml',
      'ldap_uri = ldapi://%2fvar%2frun%2fslapd-EXAMPLE-COM.socket',
      'enable_ra = True',
      'ra_plugin = dogtag',
      'dogtag_version = 10',
      'mode = production'
    ].join("\n")
  }

  let (:ipa_env) {
    [
      '  domain: example.com',
      '  server: ipaserver.example.com',
      '  realm:  EXAMPLE.COM',
      '  basedn: dc=example,dc=com'
    ].join("\n")
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context 'host is joined to IPA domain' do
    context 'IPA server is available' do
      it 'should return hash with joined status, IPA domain and IPA server' do
        Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
        Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
        File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
        File.expects(:read).with('/etc/ipa/default.conf').returns(default_conf)
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env --server host').returns("  host: ipaserver.example.com\n")
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain server realm basedn tls_ca_cert').returns(ipa_env)

        expect(Facter.fact('ipa').value).to eq({
          'connected' => true,
          'domain'    => 'example.com',
          'server'    => 'ipaserver.example.com',
          'realm'     => 'EXAMPLE.COM',
          'basedn'    => 'dc=example,dc=com'
        })
      end
    end

=begin
    context 'IPA server is not available' do
      it 'should return hash with joined status, IPA domain and IPA server' do
        Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
        Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
        File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
        IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
        Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env --server host').returns('')
        Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain server realm basedn tls_ca_cert').returns(ipa_env)

        expect(Facter.fact('ipa').value).to eq({
          'connected' => false,
          'domain'    => 'example.com',
          'server'    => 'ipaserver.example.com',
          'realm'     => 'EXAMPLE.COM',
          'basedn'    => 'dc=example,dc=com'
        })
      end
    end
=end
  end
=begin
  context 'kinit executable is not available' do
    it 'should return nil' do
      Facter::Core::Execution.expects(:which).with('kinit').returns(nil)
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')

      expect(Facter.fact('ipa').value).to be nil
    end
  end

  context 'ipa executable is not available' do
    it 'should return nil' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns(nil)

      expect(Facter.fact('ipa').value).to be nil
    end
  end

  context '/etc/ipa/default.conf is not available' do
    it 'should return nil' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(false)

      expect(Facter.fact('ipa').value).to be nil
    end

    context 'the IPA server is available' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(false)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env --server host').returns("  host: ipaserver.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain server realm basedn tls_ca_cert').returns(ipa_env)

      expect(Facter.fact('ipa').value).to eq({
        'connected' => true,
        'domain'    => 'example.com',
        'server'    => 'ipaserver.example.com',
        'realm'     => 'EXAMPLE.COM',
        'basedn'    => 'dc=example,dc=com'
      })
    end

    context 'the IPA server is not available' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(false)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env --server host').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain server realm basedn tls_ca_cert').returns(ipa_env)

      expect(Facter.fact('ipa').value).to eq({
        'connected' => false,
        'domain'    => 'example.com',
        'server'    => 'ipaserver.example.com',
        'realm'     => 'EXAMPLE.COM',
        'basedn'    => 'dc=example,dc=com'
      })
    end
  end
=end
end
