require 'spec_helper_acceptance'

test_name 'to_string function'

describe 'to_string function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "when to_string called" do
      let (:manifest) {
        <<-EOS
        $var1 = to_string(10)
        $var2 = undef

        simplib::inspect('var1', 'oneline_json')
        simplib::inspect('var2', 'oneline_json')
        EOS
      }

      it 'should return a string and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expect(results.output).to match(/Notice: Type => String Content => "10"/)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('to_string is deprecated, please use simplib::to_string')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::to_string" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::to_string(-1)
        $var2 = undef

        simplib::inspect('var1', 'oneline_json')
        simplib::inspect('var2', 'oneline_json')
        EOS
      }

      it 'should return a string without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expect(results.output).to match(/Notice: Type => String Content => "-1"/)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('to_string is deprecated, please use simplib::to_string')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
