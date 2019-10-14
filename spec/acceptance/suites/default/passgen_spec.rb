require 'spec_helper_acceptance'
require 'shellwords'

test_name 'simplib::passgen function'
if ENV['BEAKER_fips'] == 'yes'
  hash_algorithms = [ "sha256", "sha512" ]
else
  hash_algorithms = [ "md5", "sha256", "sha512"]
end

describe 'simplib::passgen function' do

  hosts.each do |server|
    hash_algorithms.each do |hash|
      (1..10).each do |round|
        # This test does exercise simplib::passgen, but since simplib::passgen
        # does not validate a generated password against any pam settings,
        # (e.g., make sure it passes pwscore), using it for local user passwords
        # IRL may not be advised.
        context "when set user 'testuser#{round}#{hash}' password of hash type == #{hash} on #{server}" do
          let(:manifest) {
            <<-EOS
            # generate the most complex password possible and print out so
            # we have access to it
            $password = simplib::passgen('testuser-#{hash}-#{round}', {'complexity' => 2, 'complex_only' => true})
            notify { "password=<${password}> for testuser-#{hash}-#{round}": }

            # use hash of the generated password for a user's password
            $hashed_password = simplib::passgen('testuser-#{hash}-#{round}', {'hash' => '#{hash}', 'complexity' => 2, 'complex_only' => true})
            user { "testuser#{round}#{hash}":
              shell => "/bin/bash",
              managehome => true,
              password => $password,
            }
            EOS
          }

          it 'should be able to create user with the generated password and then login with that password' do
            result = apply_manifest_on(server, manifest)
            password = result.stdout.match(/password=<(.*)> for testuser/)[1]

            result = on(server, "echo #{Shellwords.escape(password)} | su -c whoami testuser#{round}#{hash}")
            expect(result.stdout).to eql("testuser#{round}#{hash}\n")
          end
        end
      end
    end
  end
end
