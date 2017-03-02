require 'spec_helper_acceptance'

test_name 'passgen function'
cases = {
	"with no libkv" => {
	},
	"with libkv == false" => {
		"libkv" => false
	},
	"with libkv == true" => {
		"libkv" => true
	}
}
describe 'passgen function' do
  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
	  cases.each do |description, settings|
		  context description do
    [ "md5", "sha256", "sha512"].each do |hash|
      (1..10).each do |round|
      context "when set user 'testuser#{round}' to password 'test' and hash type == #{hash}" do
        let (:manifest) {
          <<-EOS
          $password = passgen('testuser-#{hash}-#{round}', {'hash' => '#{hash}', 'password' => 'test', 'complexity' => 2, 'complex_only' => true, 'libkv' => #{settings['libkv']}})
          notify { "$password": }
          user { "testuser#{round}":
            shell => "/bin/bash",
            managehome => true,
            password => $password,
          }
          EOS
        }
        it 'should be able to su' do
          apply_manifest_on(server, manifest)
          result = on(server, "echo 'test' | su -c whoami testuser#{round}")
          expect(result.stdout).to eql("testuser#{round}\n")
        end
      end
      end
    end
      end
    end
  end
end
