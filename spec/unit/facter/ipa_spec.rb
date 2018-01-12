require 'spec_helper'

describe "custom fact ipa" do
  let (:default_conf) {
    [
      "host = client.example.com\n",
      "basedn = dc=example,dc=com\n",
      "realm = EXAMPLE.COM\n",
      # In next 2 config lines, artificially prepend domain and IPA
      # server with 'default.' so we can validate parsing.
      "domain = default.example.com\n",
      "xmlrpc_uri = https://default.ipaserver.example.com/ipa/xml\n",
      "ldap_uri = ldapi://%2fvar%2frun%2fslapd-EXAMPLE-COM.socket\n",
      "enable_ra = True\n",
      "ra_plugin = dogtag\n",
      "dogtag_version = 10\n",
      "mode = production\n"
    ]
  }

  let (:host_info) { <<EOM
  Host name: client.example.com
  Principal name: host/client.example.com@EXAMPLE.COM
  Principal alias: host/client.example.com@EXAMPLE.COM
  SSH public key fingerprint: SHA256:m8TatOcxcXkhtd80EQjJUJG2zYUctl1EkoroadusTeU (ssh-rsa),
                              SHA256:XI7tRHoZuQJ7nc63t0hlVaQ0sP/RJcvMmMAt83jwVzE (ecdsa-sha2-nistp256),
                              SHA256:PmgNsbCMj40etrpL+f5lLnDGLWpwkvb/s7RmYTKQKfE (ssh-ed25519)
  Password: False
  Keytab: True
  Managed by: ipaserver.example.com
EOM
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context 'host is joined to IPA domain and can communicate with IPA server' do
    it 'should return hash with joined status, IPA domain and IPA server' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa host-show client.example.com').returns(host_info)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("  domain: example.com\n")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'joined',
        'domain' => 'example.com',
        'server' => 'ipaserver.example.com'
      })
    end
  end

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
  end

  context 'kinit fails' do
    it "should return hash of unknown status and nil IPA domain and server if 'kinit' returns nil" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns(nil)

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => nil,
        'server' => nil
      })
    end

    it "should return hash with unknown status and nil IPA domain and server if 'kinit' fails" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      err_msg = "kinit: Cannot contact any KDC for realm 'EXAMPLE.COM' while getting initial credentials"
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns(err_msg)

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => nil,
        'server' => nil
      })
    end
  end

  context 'ipa server is not available from the IPA client environment' do
    it "should return hash with unknown status and nil server if exec of 'ipa env host' returns nil" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns(nil)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("  domain: example.com")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => 'example.com',
        'server' => nil
      })
    end

    it "should return hash with unknown status and nil server if exec of 'ipa env host' is empty" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("  domain: example.com")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => 'example.com',
        'server' => nil
      })
    end

    it "should return hash with unknown status and nil server if 'ipa host-show' fails" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa host-show client.example.com').returns(nil)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("  domain: example.com")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => 'example.com',
        'server' => nil
      })
    end

    it "should return hash with unknown status and nil server if 'ipa host-show' does not have 'Managed by:' line" do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa host-show client.example.com').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("  domain: example.com")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => 'example.com',
        'server' => nil
      })
    end
  end

  context 'when ipa domain is not available from the IPA client environment' do
    it 'should return hash with unknown status and nil domain if domain is nil' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa host-show client.example.com').returns(host_info)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns(nil)

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => nil,
        'server' => 'ipaserver.example.com'
      })
    end

    it 'should return hash with unknown status and nil domain if domain is empty' do
      Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
      Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
      File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
      IO.expects(:readlines).with('/etc/ipa/default.conf').returns(default_conf)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/kinit -k 2>&1').returns('')
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env host').returns("  host: client.example.com\n")
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa host-show client.example.com').returns(host_info)
      Facter::Core::Execution.expects(:exec).with('/usr/bin/ipa env domain').returns("\n")

      expect(Facter.fact('ipa').value).to eq({
        'default_domain' => 'default.example.com',
        'default_server' => 'default.ipaserver.example.com',
        'status' => 'unknown',
        'domain' => nil,
        'server' => 'ipaserver.example.com'
      })
    end
  end
end
