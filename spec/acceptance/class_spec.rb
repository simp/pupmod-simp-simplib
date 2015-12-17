require 'spec_helper_acceptance'

test_name 'simplib class'

describe 'simplib class' do
  let(:default_hieradata) {{
    'simplib::sysctl::enable_ipv6' => false
  }}

  let(:manifest) {
    <<-EOS
      include 'simplib'
    EOS
  }

  let(:include_sysctl) {
    <<-EOS
      include 'simplib::sysctl'
    EOS
  }

  hosts.each do |host|
    context 'default parameters' do

      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should apply sysctl with no errors' do
        apply_manifest_on(host, include_sysctl, :catch_failures => true)
      end

      it 'sysctl should enable ipv6 by default' do
        on host, "sysctl -n net.ipv6.conf.all.disable_ipv6 | grep '0'", :acceptable_exit_codes => [0]
      end

    end

    context 'sysctl with enable ipv6 = false' do

      it 'set hieradata' do
        set_hieradata_on(host, default_hieradata)
      end

      it 'should apply sysctl with no errors' do
        apply_manifest_on(host, include_sysctl, :catch_failures => true)
      end

      it 'should disable ipv6' do
        on host, "sysctl -n net.ipv6.conf.all.disable_ipv6 | grep '1'", :acceptable_exit_codes => [0]
      end
    end
  end
end
