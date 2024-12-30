require 'spec_helper_acceptance'

test_name 'reboot_notify'
describe 'reboot_notify' do
  hosts.each do |host|
    context "on #{host}" do
      context 'when hooked into a trigger' do
        let(:manifest) do
          <<~EOS
            exec { '/bin/touch /tmp/__tmpfile__':
              creates => '/tmp/__tmpfile__',
              notify  => [
                Reboot_notify['test'],
                Class['simplib::reboot_notify']
              ]
            }
            reboot_notify { 'test': }
            include 'simplib::reboot_notify'
            reboot_notify { 'test2': reason => 'second test' }
          EOS
        end

        it 'applies cleanly' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do # rubocop:disable RSpec/RepeatedExample
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        it 'does not display notifications after reboot' do
          if host[:hypervisor] == 'docker'
            skip 'Reboot notification clearing does not work in Docker'
          else
            host.reboot
            result = apply_manifest_on(host, manifest).stdout
            expect(result).not_to match(%r{System Reboot Required Because:})
          end
        end

        it 'remains idempotent' do # rubocop:disable RSpec/RepeatedExample
          apply_manifest_on(host, manifest, catch_changes: true)
        end
      end

      context 'with log_level set to debug' do
        let(:manifest) do
          <<~EOS
            reboot_notify { 'test': }
            exec { '/bin/touch /tmp/__tmpfile2__':
              creates => '/tmp/__tmpfile2__',
              notify  => [
                Reboot_notify['test'],
                Class['simplib::reboot_notify']
              ]
            }
            class { 'simplib::reboot_notify':
              log_level => 'debug'
            }
            reboot_notify { 'test2': reason => 'second test' }
          EOS
        end

        it 'applies cleanly' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        it 'does not display reboot notifications' do
          result = apply_manifest_on(host, manifest).stdout
          expect(result).not_to match(%r{System Reboot Required Because:})
        end
      end
    end
  end
end
