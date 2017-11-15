require 'spec_helper_acceptance'

test_name 'validate_net_list function'

describe 'validate_net_list function' do
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
    context "when validate_net_list called" do

      it 'should accept valid netlist' do
        manifest = <<-EOS
        $var1 = ['10.10.10.0/24','1.2.3.4','1.3.4.5:400']
        validate_net_list($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_net_list is deprecated, please use simplib::validate_net_list')
        end

        expect(deprecation_lines.size).to eq 1
      end

      it 'should reject invalid netlists' do
        manifest = <<-EOS
        $var1 = '10.10.10.0/24,1.2.3.4'
        validate_net_list($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_net_list is deprecated, please use simplib::validate_net_list')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "when simplib::validate_net_list" do
      it 'should accept valid netlists' do
        manifest = <<-EOS
        $var1 = ['20.20.20.0/24','4.3.2.1','6.4.3.1:800']
        simplib::validate_net_list($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_net_list is deprecated, please use simplib::validate_net_list')
        end

        expect(deprecation_lines.size).to eq 0
      end

      it 'should reject invalid netlists' do
        manifest = <<-EOS
        $var1 = 'bad stuff'
        simplib::validate_net_list($var1)
        EOS
        results = apply_manifest_on(server, manifest, opts_with_exit_1)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('validate_net_list is deprecated, please use simplib::validate_net_list')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
