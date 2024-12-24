require 'spec_helper_acceptance'

test_name 'simplib::to_string function'

describe 'simplib::to_string function' do
  hosts.each do |server|
    context "when simplib::to_string called on #{server}" do
      let(:manifest) do
        <<~EOS
          $var1 = simplib::to_string(-1)
          $var2 = undef

          simplib::inspect('var1', 'oneline_json')
          simplib::inspect('var2', 'oneline_json')
        EOS
      end

      it 'returns a string' do
        results = apply_manifest_on(server, manifest)

        expect(results.output).to match(%r{Notice: Type => String Content => "-1"})
        expect(results.output).to match(%r{Notice: Type => NilClass Content => null})
      end
    end
  end
end
