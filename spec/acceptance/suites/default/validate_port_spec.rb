require 'spec_helper_acceptance'

test_name 'validate_port function'

describe 'validate_port function' do
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
    context "when validate_port called" do

      it 'should accept valid ports' do
        manifest = <<-EOS
        $var1 = validate_port(10)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_port is deprecated, please use simplib::validate_port')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject invalid ports' do
        manifest = <<-EOS
        $var1 = validate_port(0)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_port is deprecated, please use simplib::validate_port')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::validate_port" do
      it 'should accept valid ports' do
        manifest = <<-EOS
        $var1 = simplib::validate_port(20)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_port is deprecated, please use simplib::validate_port')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject invalid ports' do
        manifest = <<-EOS
        $var1 = simplib::validate_port('65535')
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_port is deprecated, please use simplib::validate_port')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
