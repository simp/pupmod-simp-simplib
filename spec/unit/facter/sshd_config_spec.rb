require 'spec_helper'

describe "custom fact implib__sshd_config" do

  before(:each) do
    Facter.clear

  end

  context 'with a simp /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
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
    }
    it 'should return hash of values from /etc/ssh/sshd_config' do
      File.expects(:exist?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:readable?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:read).with('/etc/ssh/sshd_config').returns(sshd_config_content)

      # This resets the stubbing code in Mocha to ensure that the code does not
      # try to catch any other calls to the stubbed methods above.
      #
      # This is not documented well and is almost always what you want in
      # Puppet testing

      File.stubs(:exist?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:readable?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:read).with(Not(equals('/etc/ssh/sshd_config')))
      expect(Facter.fact('simplib__sshd_config').value).to eq({"authorizedkeysfile"=>"/etc/ssh/local_keys/%u"})
    end
  end

  context 'with a default /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
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
    }

    it 'should return hash of values from /etc/ssh/sshd_config' do
      File.expects(:exist?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:readable?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:read).with('/etc/ssh/sshd_config').returns(sshd_config_content)
      # Reset stubbing
      File.stubs(:exist?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:readable?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:read).with(Not(equals('/etc/ssh/sshd_config')))
      expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'authorizedkeysfile' => '.ssh/authorized_keys' })
    end
  end

  context 'with a commented values /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
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
    }

    it 'should return hash of values from /etc/ssh/sshd_config' do
      File.expects(:exist?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:readable?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:read).with('/etc/ssh/sshd_config').returns(sshd_config_content)
      # Reset stubbing
      File.stubs(:exist?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:readable?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:read).with(Not(equals('/etc/ssh/sshd_config')))
      expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'authorizedkeysfile' => '.ssh/authorized_keys' })
    end
  end


  context 'with empty /etc/ssh/sshd_config' do

    it 'should return the ssh default value' do
      File.expects(:exist?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:readable?).with('/etc/ssh/sshd_config').returns(true)
      File.expects(:read).with('/etc/ssh/sshd_config').returns('')
      # Reset stubbing
      File.stubs(:exist?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:readable?).with(Not(equals('/etc/ssh/sshd_config')))
      File.stubs(:read).with(Not(equals('/etc/ssh/sshd_config')))
      expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'authorizedkeysfile' => '.ssh/authorized_keys' })
    end
  end
end
