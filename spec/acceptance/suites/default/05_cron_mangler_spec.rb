require 'spec_helper_acceptance'

test_name 'cron munging function'

describe 'setting up services' do
  cronspecs = [
    "'*', '*', '*', '*', '*'",
    "'0', '0', '1', '*', '1'",
    "'0', '0', '2', '5', '1'",
    "'*', '0', '*', '5', '*'",
    "'0', '*', '3', '*', '1'",
    "'0/5', '*', '5', '*', '1'",
    "'0-5', '*', '6', '*', '1'",
    "'5', '0', '*', '*', '*'",
    "'15', '14', '1', '*', '*'",
    "'0', '22', '*', '*', '1-5'",
    "'23', '0-20/2', '*', '*', '*'",
    "'5', '4', '*', '*', 'sun'",
  ]

  hosts.each do |host|
    context "on #{host}" do
      cronspecs.each do |cronspec|
        context "with #{cronspec}" do
          manifest = <<~MANIFEST
            $calendar = simplib::cron::to_systemd(#{cronspec})

            $timer = @("EOM")
            [Timer]
            OnCalendar=${calendar}
            | EOM

            $service = @("EOM")
            [Service]
            Type=oneshot
            ExecStart=/bin/true
            | EOM

            systemd::timer { 'beaker_test.timer':
              timer_content   => $timer,
              service_content => $service,
              active          => true,
              enable          => true
            }
          MANIFEST

          it 'runs successfully' do
            apply_manifest_on(host, manifest, catch_failures: true)
          end

          it 'is idempotent' do
            apply_manifest_on(host, manifest, catch_changes: true)
          end
        end
      end
    end
  end
end
