require 'spec_helper_acceptance'

test_name 'simplib class'

describe 'simplib class' do
  let(:manifest) {
    <<-EOS
      include 'simplib'
    EOS
  }

  hosts.each do |host|
    context 'default parameters' do

      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end
    end
  end
end
