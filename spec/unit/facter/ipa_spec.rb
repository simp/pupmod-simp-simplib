require 'spec_helper'

describe "custom fact ipa" do
  before :each do
    allow(File).to receive(:read).with(any_args).and_call_original
  end

  let (:ipa_query_options) {
    {:timeout => 30}
  }

  let (:kinit_query_options) {
    {:timeout => 10}
  }

  let (:ipa_env_query) {
    '/bin/true && LC_ALL=en_US.UTF-8 /usr/bin/ipa env domain server realm basedn tls_ca_cert'
  }

  let (:ipa_env_server_query) {
    '/bin/true && LC_ALL=en_US.UTF-8 /usr/bin/ipa env --server host'
  }

  let (:default_conf) {
    [
      '#host = client.example.com',
      'host=client.example.com',
      'basedn = dc=example,dc=com',
      'realm = EXAMPLE.COM',
      'domain = example.com',
      'server = ipaserver.example.com',
      'xmlrpc_uri = https://ipaserver.example.com/ipa/xml',
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
      '  basedn: dc=example,dc=com',
      '-----------',
      '4 variables',
      '-----------'
    ].join("\n")
  }

  let (:ipa_server_env) {
    'host: ipaserver.example.com'
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    # Facter 4
    if defined?(Facter::Resolvers::Uname)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(any_args).and_return('Linux')
    else
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
    end
  end

  context 'host is joined to IPA domain' do

    before(:each) do
      allow(ENV).to receive(:fetch).with('LANG', 'en_US.UTF-8').and_return('en_US.UTF-8')
      allow(Facter::Core::Execution).to receive(:which).with('kinit').and_return('/usr/bin/kinit')
      allow(Facter::Core::Execution).to receive(:which).with('klist').and_return('/usr/bin/klist')
      allow(Facter::Core::Execution).to receive(:which).with('ipa').and_return('/usr/bin/ipa')
      allow(Facter::Core::Execution).to receive(:which).with('true').and_return('/bin/true')
    end

    context 'IPA server is available' do
      context 'kinit is not required' do
        before(:each) do
          allow(File).to receive(:exist?).with('/etc/ipa/default.conf').and_return(true)
          allow(File).to receive(:read).with('/etc/ipa/default.conf').and_return(default_conf.dup)
          allow(Puppet::Util::Execution).to receive(:execute).with('/usr/bin/klist -s').and_return(Puppet::Util::Execution::ProcessOutput.new('', 0))
          allow(Facter::Core::Execution).to receive(:execute).with(ipa_env_query, ipa_query_options).and_return(ipa_env)
          allow(Facter::Core::Execution).to receive(:execute).with(ipa_env_server_query, ipa_query_options).and_return(ipa_server_env)
        end

        it 'should execute only ipa commands and report local env + connected status' do
          # Have to set $? for Facter 4
          %x{( exit 0 )}
          expect(Facter.fact('ipa').value).to eq({
            'connected' => true,
            'domain'    => 'example.com',
            'server'    => 'ipaserver.example.com',
            'realm'     => 'EXAMPLE.COM',
            'basedn'    => 'dc=example,dc=com'
          })
        end
      end

      context 'kinit is required' do
        before(:each) do
          allow(File).to receive(:exist?).with('/etc/ipa/default.conf').and_return(true)
          allow(File).to receive(:read).with('/etc/ipa/default.conf').and_return(default_conf)
          allow(Puppet::Util::Execution).to receive(:execute).with('/usr/bin/klist -s').and_return(Puppet::Util::Execution::ProcessOutput.new('', 1))
          allow(Facter::Core::Execution).to receive(:execute).with('/usr/bin/kinit -k 2>&1', kinit_query_options).and_return('')
          allow(Facter::Core::Execution).to receive(:execute).with(ipa_env_query, ipa_query_options).and_return(ipa_env)
          allow(Facter::Core::Execution).to receive(:execute).with(ipa_env_server_query, ipa_query_options).and_return(ipa_server_env)
        end

        it 'should execute kinit + ipa commands and return local env + connected status' do
          expect(Facter.fact('ipa').value).to eq({
            'connected' => true,
            'domain'    => 'example.com',
            'server'    => 'ipaserver.example.com',
            'realm'     => 'EXAMPLE.COM',
            'basedn'    => 'dc=example,dc=com'
          })
        end
      end
    end

    context 'IPA server is not available' do
      before(:each) do
        allow(File).to receive(:exist?).with('/etc/ipa/default.conf').and_return(true)
        allow(File).to receive(:read).with('/etc/ipa/default.conf').and_return(default_conf)
        allow(Puppet::Util::Execution).to receive(:execute).with('/usr/bin/klist -s').and_return(Puppet::Util::Execution::ProcessOutput.new('', 1))
        allow(Facter::Core::Execution).to receive(:execute).with('/usr/bin/kinit -k 2>&1', kinit_query_options).and_return('some error message')
        allow(Facter::Core::Execution).to receive(:execute).with(ipa_env_query, ipa_query_options).and_return('')
      end

      it 'should return defaults from /etc/ipa/default.conf and disconnected status' do
        expect(Facter.fact('ipa').value).to eq({
          'connected' => false,
          'domain'    => 'example.com',
          'server'    => 'ipaserver.example.com',
          'realm'     => 'EXAMPLE.COM',
          'basedn'    => 'dc=example,dc=com'
        })
      end
    end
  end
end
