require 'spec_helper_acceptance'

test_name 'validate_between function'

describe 'validate_between function' do
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
    context 'when validate_between called' do

      it 'should accept element within range' do
        manifest = <<-EOS
        $var1 = 7
        validate_between($var1, 0, 60)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_between is deprecated, please use simplib::validate_between')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should allow element outside of range because of bug' do
        manifest = <<-EOS
        $var1 = 70
        validate_between($var1, 0, 60)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_between is deprecated, please use simplib::validate_between')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context 'when simplib::validate_between' do
      it 'should accept element within range' do
        manifest = <<-EOS
        $var1 = 7
        simplib::validate_between($var1, 0, 60)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_between is deprecated, please use simplib::validate_between')
        end

        expect(deprecation_lines.size).to eq 0
      end

      # bug in original code...returned false
      it 'should reject element outside of range' do
        manifest = <<-EOS
        $var1 = 70
        simplib::validate_between($var1, 0, 60)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_between is deprecated, please use simplib::validate_between')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
