require 'spec_helper_acceptance'

test_name 'strip_ports function'

describe 'strip_ports function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "when strip_ports called" do
      let (:manifest) {
        <<-EOS
        $var1 = strip_ports(['1.2.3.4', 'https://1.2.3.4:443'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should tranform the host list and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expect(results.output).to match(
          %r(Notice: Type => Array Content => \["1.2.3.4"\])
        )

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('strip_ports is deprecated, please use simplib::strip_ports')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::strip_ports" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::strip_ports(['my.example.net:900', 'my.example.net:700'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should transform the host list without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expect(results.output).to match(
          %r(Notice: Type => Array Content => \["my.example.net"\])
        )

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('strip_ports is deprecated, please use simplib::strip_ports')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
