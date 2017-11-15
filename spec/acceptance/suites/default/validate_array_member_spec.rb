require 'spec_helper_acceptance'

test_name 'validate_array_member function'

describe 'validate_array_member function' do
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
    context 'when validate_array_member called' do

      it 'should accept element that is in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        validate_array_member($var1, ['foo', 'FOO'])
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_array_member is deprecated, please use simplib::validate_array_member')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject element that is not in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        validate_array_member($var1, ['bar', 'BAR'])
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_array_member is deprecated, please use simplib::validate_array_member')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context 'when simplib::validate_array_member' do
      it 'should accept element that is in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        simplib::validate_array_member($var1, ['foo', 'FOO'])
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_array_member is deprecated, please use simplib::validate_array_member')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject element that is not in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        simplib::validate_array_member($var1, ['bar', 'BAR'])
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_array_member is deprecated, please use simplib::validate_array_member')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
