require 'spec_helper_acceptance'

test_name 'parse_hosts function'

describe 'parse_hosts function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "when parse_hosts called" do
      let (:manifest) {
        <<-EOS
        $var1 = parse_hosts(['1.2.3.4', 'https://1.2.3.4:443'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should tranform the host list and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expected_content = %q({"1.2.3.4":{"ports":\["443"\],"protocols":{"https":\["443"\]}}})
        expect(results.output).to match(
          %r(Notice: Type => Hash Content => #{expected_content})
        )

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('parse_hosts is deprecated, please use simplib::parse_hosts')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::parse_hosts" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::parse_hosts(['my.example.net:900', 'my.example.net:700'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should transform the host list without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expected_content = %q({"my.example.net":{"ports":\["700","900"\],"protocols":{}}})
        expect(results.output).to match(
          %r(Notice: Type => Hash Content => #{expected_content})
        )

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('parse_hosts is deprecated, please use simplib::parse_hosts')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
