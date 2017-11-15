require 'spec_helper_acceptance'

test_name 'nets2ddq function'

describe 'nets2ddq function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context 'when nets2ddq' do
      let (:manifest) {
        <<-EOS
        $var1 = [ '10.0.1.0/24', '10.0.2.0/255.255.255.0', '10.0.3.25', 'myhost' ]
        $var2 = nets2ddq($var1)

        simplib::inspect('var2')
        EOS
      }

      it 'should return a converted array and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expected_regex = %r{\["10.0.1.0\/255.255.255.0","10.0.2.0\/255.255.255.0","10.0.3.25","myhost"\]}
        expect(results.output).to match(expected_regex)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('nets2ddq is deprecated, please use simplib::nets2ddq')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context 'when simplib::nets2ddq' do
      let (:manifest) {
        <<-EOS
        $var1 = [ '10.0.1.0/24', '10.0.2.0/255.255.255.0', '10.0.3.25', 'myhost' ]
        $var2 = simplib::nets2ddq($var1)

        simplib::inspect('var2')
        EOS
      }

      it 'should return a converted array without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expected_regex = %r{\["10.0.1.0\/255.255.255.0","10.0.2.0\/255.255.255.0","10.0.3.25","myhost"\]}
        expect(results.output).to match(expected_regex)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('nets2ddq is deprecated, please use simplib::nets2ddq')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
