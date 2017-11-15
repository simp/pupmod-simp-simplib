require 'spec_helper_acceptance'

test_name 'validate_deep_hash function'

describe 'validate_deep_hash function' do
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
    context 'when validate_deep_hash called' do

      it 'should accept valid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.bar.com' }
        validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_deep_hash is deprecated, please use simplib::validate_deep_hash')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject invalid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.baz.com' }
        validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_deep_hash is deprecated, please use simplib::validate_deep_hash')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context 'when simplib::validate_deep_hash' do
      it 'should accept valid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.bar.com' }
        simplib::validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_deep_hash is deprecated, please use simplib::validate_deep_hash')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject invalid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.baz.com' }
        simplib::validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_deep_hash is deprecated, please use simplib::validate_deep_hash')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
