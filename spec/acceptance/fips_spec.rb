require 'spec_helper_acceptance'

test_name 'FIPS Test'

describe 'FIPS Test' do
  let(:hieradata_enable_fips) {
    {
      'simplib::use_fips' => true
    }
  }

  let(:manifest) {
    <<-EOS
      class { 'simplib': }
    EOS
  }

  hosts.each do |host|

    context 'default parameters' do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should require reboot on subsequent run' do
        result = apply_manifest_on(host, manifest, :catch_failures => true)
        expect(result.output).to include('fips => modified')

        # Reboot to disable fips in the kernel
        host.reboot
      end

      it 'should have kernel-level FIPS disabled on reboot' do
        expect(fact_on(host,'fips_enabled', { :puppet => nil })).to eq('false')
      end
    end

    context 'Enable FIPS' do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        set_hieradata_on(host, hieradata_enable_fips)
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should require reboot on subsequent run' do
        result = apply_manifest_on(host, manifest, :catch_failures => true)
        expect(result.output).to include('fips => modified')

        # Reboot to enable auditing in the kernel
        host.reboot
      end

      it 'should have kernel-level FIPS enabled on reboot' do
        expect(fact_on(host,'fips_enabled', { :puppet => nil })).to eq('true')
      end

      it 'should have the dracut-fips package installed' do
        result = on(host, 'puppet resource package dracut-fips')
        expect(result.output).to_not include("ensure => 'absent'")
      end

      it 'should have the dracut-fips-aesni package installed' do
        if JSON.parse(fact_on(host,'cpuinfo', { :puppet => nil, :json => nil }))['cpuinfo']['processor0']['flags'].include?('aes')
          result = on(host, 'puppet resource package dracut-fips-aesni')
          expect(result.output).to_not include("ensure => 'absent'")
        end
      end
    end

    context 'disabling FIPS at the kernel level' do
      it 'should be the default state' do
        set_hieradata_on(host, { 'garbage_value' => 'garbage' })
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should require reboot on subsequent run' do
        result = apply_manifest_on(host, manifest, :catch_failures => true)
        expect(result.output).to include('fips => modified')

        # Reboot to disable fips in the kernel
        host.reboot
      end

      it 'should have kernel-level FIPS disabled on reboot' do
        expect(fact_on(host,'fips_enabled', { :puppet => nil })).to eq('false')
      end
    end
  end
end
