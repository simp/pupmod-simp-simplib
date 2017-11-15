require 'spec_helper_acceptance'

test_name 'validate_uri_list function'

describe 'validate_uri_list function' do
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
    context "when validate_uri_list called" do

      it 'should accept valid URIs' do
        manifest = <<-EOS
        $var1 = validate_uri_list('https://1.2.3.4:56', ['http','https'])
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_uri_list is deprecated, please use simplib::validate_uri_list')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject invalid URIs' do
        manifest = <<-EOS
        $var1 = validate_uri_list('ldap://1.2.3.4:56', ['http','https'])
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_uri_list is deprecated, please use simplib::validate_uri_list')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::validate_uri_list" do
      it 'should accept valid URIs' do
        manifest = <<-EOS
        $var1 = simplib::validate_uri_list('https://1.2.3.4:56', ['http','https'])
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_uri_list is deprecated, please use simplib::validate_uri_list')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject invalid URIs' do
        manifest = <<-EOS
        $var1 = simplib::validate_uri_list('ldap://1.2.3.4:56', ['http','https'])
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_uri_list is deprecated, please use simplib::validate_uri_list')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
