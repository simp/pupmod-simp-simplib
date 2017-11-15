require 'spec_helper_acceptance'

test_name 'to_integer function'

describe 'to_integer function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "when to_integer called" do
      let (:manifest) {
        <<-EOS
        $var1 = to_integer('10')
        $var2 = to_integer(' 2345 ')

        simplib::inspect('var1', 'oneline_json')
        simplib::inspect('var2', 'oneline_json')
        EOS
      }

      it 'should return an integer and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expect(results.output).to match(/Notice: Type => Fixnum Content => 10/)
        expect(results.output).to match(/Notice: Type => Fixnum Content => 2345/)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('to_integer is deprecated, please use simplib::to_integer')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::to_integer" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::to_integer('-1')
        $var2 = simplib::to_integer('24')

        simplib::inspect('var1', 'oneline_json')
        simplib::inspect('var2', 'oneline_json')
        EOS
      }

      it 'should return an integer without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest)

        expect(results.output).to match(/Notice: Type => Fixnum Content => -1/)
        expect(results.output).to match(/Notice: Type => Fixnum Content => 24/)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('to_integer is deprecated, please use simplib::to_integer')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
