require 'spec_helper_acceptance'

test_name 'simplib::caller function'

describe 'simplib::caller function' do
  let(:manifest) do
    <<~EOM
      include testmod
    EOM
  end

  hosts.each do |host|
    host_modulepath = puppet_modulepath_on(host).first

    install_local_module_on(host, File.absolute_path(File.join(__dir__, 'files', 'modules', 'testmod')))

    it 'returns the correct location' do
      results = apply_manifest_on(host, manifest).output

      expect(results).to match(%r{#{host_modulepath}/testmod/manifests/init.pp}m)
    end
  end
end
