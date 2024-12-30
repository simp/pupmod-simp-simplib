require 'spec_helper'

describe 'custom fact login_defs' do
  before(:each) do
    Facter.clear

    allow(Facter).to receive(:value).with(any_args).and_call_original
    allow(File).to receive(:read).with(any_args).and_call_original
    allow(File).to receive(:readable?).with(any_args).and_call_original
  end

  context 'with a well formed /etc/login.defs' do
    let(:login_defs_content) do
      <<~EOM
        # I can haz comments!
        MAIL_DIR        /var/spool/mail

        PASS_MAX_DAYS   99999
        PASS_MIN_DAYS   0

        PASS_MIN_LEN    5

        PASS_WARN_AGE   7

        UID_MIN         1000
        UID_MAX         60000

        SYS_UID_MIN     201
        SYS_UID_MAX     999

        GID_MIN         1000
        GID_MAX         60000

        SYS_GID_MIN     201
        SYS_GID_MAX     999

        CREATE_HOME     yes

        UMASK           077
        USERGROUPS_ENAB yes
        #{'    '}
        # Even inline comments!
            # And indented comments
        ENCRYPT_METHOD  SHA512
        MD5_CRYPT_ENAB  no
      EOM
    end

    it 'returns hash of values from /etc/login.defs with appropriate conversions' do
      expect(File).to receive(:exist?).with('/etc/login.defs').and_return(true)
      expect(File).to receive(:readable?).with('/etc/login.defs').and_return(true)
      expect(File).to receive(:read).with('/etc/login.defs').and_return(login_defs_content)

      expect(Facter.fact('login_defs').value).to eq(
        {
          'mail_dir' => '/var/spool/mail',
          'pass_max_days' => 99_999,
          'pass_min_days' => 0,
          'pass_min_len' => 5,
          'pass_warn_age' => 7,
          'uid_min' => 1000,
          'uid_max' => 60_000,
          'sys_uid_min' => 201,
          'sys_uid_max' => 999,
          'gid_min' => 1000,
          'gid_max' => 60_000,
          'sys_gid_min' => 201,
          'sys_gid_max' => 999,
          'create_home' => true,
          'umask' => '077',
          'usergroups_enab' => true,
          'encrypt_method' => 'SHA512',
          'md5_crypt_enab' => false,
        },
      )
    end
  end

  context 'with an empty login.defs' do
    it 'returns hash of the uid_min and gid_min defaults' do
      expect(File).to receive(:exist?).with('/etc/login.defs').and_return(true)
      expect(File).to receive(:readable?).with('/etc/login.defs').and_return(true)
      expect(File).to receive(:read).with('/etc/login.defs').and_return('')

      expect(Facter.fact('login_defs').value).to eq({})
    end
  end
end
