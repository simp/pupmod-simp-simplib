require 'spec_helper_acceptance'

test_name 'reboot_notify'
describe 'reboot_notify' do

  hosts.each do |host|
    context "on #{host}" do
      let (:manifest) {
        <<-EOS
        reboot_notify { 'test': }
        include 'simplib::reboot_notify'
        reboot_notify { 'test2': reason => 'second test' }
        EOS
      }
      it 'should apply cleanly' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should display reboot notifications' do
        result = apply_manifest_on(host, manifest).stdout
        expect(result).to match(/System Reboot Required Because:/)
      end

      context 'with log_level set to debug' do
        let (:manifest) {
          <<-EOS
          reboot_notify { 'test': }
          class { 'simplib::reboot_notify':
            log_level => 'debug'
          }
          reboot_notify { 'test2': reason => 'second test' }
          EOS
        }

        it 'should apply cleanly' do
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, :catch_changes => true)
        end

        it 'should not display reboot notifications' do
          result = apply_manifest_on(host, manifest).stdout
          expect(result).to_not match(/System Reboot Required Because:/)
        end
      end

      context 'when hooked into a trigger' do
        let (:manifest) {
          <<-EOS
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
        }

        it 'should apply cleanly' do
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, :catch_changes => true)
        end

        it 'should be idempotent after reboot' do
          host.reboot
          apply_manifest_on(host, manifest, :catch_changes => true)
        end

        it 'should remain idempotent' do
          apply_manifest_on(host, manifest, :catch_changes => true)
        end
      end
    end
  end
end
