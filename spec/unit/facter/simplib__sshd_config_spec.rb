require 'spec_helper'

describe 'simplib__sshd_config' do
  before :each do
    Facter.clear

    allow(File).to receive(:read).with(any_args).and_call_original
    allow(File).to receive(:readable?).with(any_args).and_call_original

    expect(Facter::Util::Resolution).to receive(:which).with('sshd').and_return('/usr/bin/sshd')
    expect(Facter::Core::Execution).to receive(:execute).with('/usr/bin/sshd -. 2>&1', on_fail: :failed).and_return(openssh_version['full_version'])

    expect(File).to receive(:exist?).with('/etc/ssh/sshd_config').and_return(true).at_least(:once)
    expect(File).to receive(:readable?).with('/etc/ssh/sshd_config').and_return(true)
    expect(File).to receive(:read).with('/etc/ssh/sshd_config').and_return(sshd_config_content)
  end

  let(:openssh_version) do
    {
      'full_version' => 'OpenSSH_7.9p1, OpenSSL 1.1.1a FIPS  20 Nov 2018',
      'version' => '7.9p1',
    }
  end

  context 'with a simp /etc/ssh/sshd_config' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        Port 22
        ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        AuthorizedKeysFile      /etc/ssh/local_keys/%u

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
        #AuthorizedKeysCommandUser nobody
        AuthorizedKeysCommandUser nobody

        # Even inline comments!
            # And indented comments
      EOM
    end

    it do
      expect(Facter.fact('simplib__sshd_config').value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '/etc/ssh/local_keys/%u' }))
    end
  end

  context 'with a default /etc/ssh/sshd_config' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        AuthorizedKeysFile      .ssh/authorized_keys

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody

        # Even inline comments!
            # And indented comments
      EOM
    end

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    end

    context 'when the SSH daemon does not return a version string' do
      let(:openssh_version) do
        {
          'full_version' => :failed,
          'version' => nil,
        }
      end

      it do
        expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' })
      end
    end

    context 'when the SSH daemon does not return a valid version string' do
      let(:openssh_version) do
        {
          'full_version' => 'OpenSSH_is amazing',
          'version' => nil,
        }
      end

      it do
        expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' })
      end
    end
  end

  context 'with a commented values /etc/ssh/sshd_config' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        #AuthorizedKeysFile       /etc/ssh/local_keys/%u

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody
      EOM
    end

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    end
  end

  context 'with empty /etc/ssh/sshd_config' do
    let(:sshd_config_content) { '' }

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    end
  end

  context 'with multiple matching entries' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        AuthorizedKeysFile       /etc/ssh/local_keys/%u
        AuthorizedKeysFile       /foo/bar/baz

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody
      EOM
    end

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        { 'AuthorizedKeysFile' => ['/etc/ssh/local_keys/%u', '/foo/bar/baz'] },
      ))
    end
  end

  context 'with multiple entries in a Match block' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        Match user foo
          AuthorizedKeysFile       /etc/ssh/local_keys/%u
          AuthorizedKeysFile       /foo/bar/baz

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody
      EOM
    end

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        {
          'AuthorizedKeysFile' => '.ssh/authorized_keys',
          'Match user foo' => {
            'AuthorizedKeysFile' => [ '/etc/ssh/local_keys/%u', '/foo/bar/baz'],
          },
        },
      ))
    end
  end

  context 'with global and Match block entries' do
    let(:sshd_config_content) do
      <<~EOM
        #Brief chunk of file
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #PubkeyAuthentication yes

        AuthorizedKeysFile       /global/time

        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        Match user foo
          AuthorizedKeysFile       /etc/ssh/local_keys/%u
          AuthorizedKeysFile       /foo/bar/baz

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody
      EOM
    end

    it do
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        {
          'AuthorizedKeysFile' => '/global/time',
          'Match user foo' => {
            'AuthorizedKeysFile' => [ '/etc/ssh/local_keys/%u', '/foo/bar/baz'],
          },
        },
      ))
    end
  end
end
