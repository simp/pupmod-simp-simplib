require 'spec_helper_acceptance'
require 'json'

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
            expect(result).not_to include('System Reboot Required Because:')
          end
        end

        it 'remains idempotent' do # rubocop:disable RSpec/RepeatedExample
          apply_manifest_on(host, manifest, catch_changes: true)
        end
      end

      context 'with ensure => absent' do
        let(:target) { File.join(on(host, 'puppet config print vardir').stdout.strip, 'reboot_notifications.json') }
        let(:records) { JSON.parse(on(host, "cat #{target}").stdout) }
        let(:trigger) do
          <<~EOS
            exec { '/bin/touch /tmp/__tmpfile3__':
              creates => '/tmp/__tmpfile3__',
              notify  => [Reboot_notify['keep'], Reboot_notify['remove']],
            }
          EOS
        end

        it 'registers both notifications' do
          apply_manifest_on(host, "#{trigger}\nreboot_notify { ['keep', 'remove']: }", catch_failures: true)

          expect(records.keys).to include('keep', 'remove')
        end

        it 'keeps a notification that is no longer declared' do
          apply_manifest_on(host, "reboot_notify { 'keep': }", catch_failures: true)

          expect(records.keys).to include('keep', 'remove')
        end

        it 'removes only its own notification' do
          result = apply_manifest_on(host, "reboot_notify { 'keep': }\nreboot_notify { 'remove': ensure => absent }", catch_failures: true)

          expect(result.output).not_to match(%r{^Error:})
          expect(result.output).to include('Reboot_notify[remove]/ensure: removed')
          expect(records.keys).to include('keep', 'reboot_control_metadata')
          expect(records.keys).not_to include('remove')
        end

        it 'is idempotent' do
          apply_manifest_on(host, "reboot_notify { 'keep': }\nreboot_notify { 'remove': ensure => absent }", catch_changes: true)
        end
      end

      context 'with --noop and no notifications' do
        let(:target) { File.join(on(host, 'puppet config print vardir').stdout.strip, 'reboot_notifications.json') }

        it 'previews cleanly without writing the target' do
          on(host, "rm -f #{target}")

          result = apply_manifest_on(host, "reboot_notify { 'noop_test': }", noop: true, catch_failures: true)

          expect(result.output).not_to match(%r{^Error:})
          expect(result.output).to include('Reboot_notify[noop_test]/ensure: created (noop)')
          expect(host.file_exist?(target)).to be false
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
          expect(result).not_to include('System Reboot Required Because:')
        end
      end
    end
  end
end
