require 'spec_helper_acceptance'

test_name 'validate_bool function'

describe 'validate_bool_simp function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  let(:opts_with_exit_1) do
    {
      :environment           => {'SIMPLIB_LOG_DEPRECATIONS' => 'true'},
      :acceptable_exit_codes => [1]
    }
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context 'when validate_bool_simp called' do

      it 'should accept valid bool equivalent' do
        manifest = <<-EOS
        $var1 = "true"
        validate_bool_simp($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_bool_simp is deprecated, please use simplib::validate_bool')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject invalid bool equivalent' do
        manifest = <<-EOS
        $var1 = "true"
        validate_bool_simp($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_bool_simp is deprecated, please use simplib::validate_bool')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context 'when simplib::validate_bool' do
      it 'should accept valid bool equivalent' do
        manifest = <<-EOS
        $var1 = "true"
        simplib::validate_bool($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_bool_simp is deprecated, please use simplib::validate_bool')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject invalid bool equivalent' do
        manifest = <<-EOS
        $var1 = "True"
        simplib::validate_bool($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_bool_simp is deprecated, please use simplib::validate_bool')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
