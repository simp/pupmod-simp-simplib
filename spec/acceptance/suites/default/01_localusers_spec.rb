require 'spec_helper_acceptance'

test_name 'localusers test'

describe 'localusers test' do

  let(:hieradata) {
    'simplib::localusers::source : "/root/localusers"'
  }

  let(:manifest) {
    'include simplib::localusers'
  }

  hosts.each do |host|
    context 'with a specified localusers file' do
      it 'should create user simp.user' do

        # Set up a localusers file
        domain = on host, "facter domain"
        user = "*.#{domain.stdout.strip},simp.user,10000,10000,/home/simp.user,foobarbaz"
        on host, "cat << EOF > /root/localusers \n#{user}\nEOF"

        # Apply the user to the system
        set_hieradata_on(host, hieradata, 'default')
        apply_manifest_on(host, manifest, :catch_failures => true)

        # Check if user exists
        result = on host, "getent passwd"
        expect(result.stdout).to include("simp.user:x:10000:10000::/home/simp.user:/bin/bash")
        result = on host, "getent group"
        expect(result.stdout).to include("simp.user:x:10000:")
        result = on host, "id simp.user"
        expect(result.stdout).to include("uid=10000(simp.user) gid=10000(simp.user) groups=10000(simp.user)")
      end
    end
  end
end
