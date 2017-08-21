require 'spec_helper_acceptance'

test_name 'ipaddresses function'

describe 'ipaddresses function' do
  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "when ipaddresses called with/without arguments" do
      let (:manifest) {
        <<-EOS
        $var1 = ipaddresses()
        $var2 = ipaddresses(true)

        simplib::inspect('var1')
        simplib::inspect('var2')
        EOS
      }

      it 'should return IP addresses and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest)

        all_ips_regex = %r{\["10.*","10.*","127.0.0.1"\]}
        expect(results.output).to match(all_ips_regex)

        remote_ips_regex = %r{\["10.*","10.*"\]}
        expect(results.output).to match(remote_ips_regex)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('ipaddresses is deprecated, please use simplib::ipaddresses')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::ipaddresses called with/without arguments" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::ipaddresses()
        $var2 = simplib::ipaddresses(true)

        simplib::inspect('var1')
        simplib::inspect('var2')
        EOS
      }

      it 'should return IP addresses without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest)

        # exact IP parsing already done in unit test
        all_ips_regex = %r{\["10.*","10.*","127.0.0.1"\]}
        expect(results.output).to match(all_ips_regex)

        remote_ips_regex = %r{\["10.*","10.*"\]}
        expect(results.output).to match(remote_ips_regex)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('ipaddresses is deprecated, please use simplib::ipaddresses')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
