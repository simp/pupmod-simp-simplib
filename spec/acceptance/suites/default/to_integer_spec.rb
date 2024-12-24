require 'spec_helper_acceptance'

test_name 'simplib::to_integer function'

describe 'simplib::to_integer function' do
  hosts.each do |server|
    context "when simplib::to_integer called on #{server}" do
      let(:manifest) do
        <<~EOS
          $var1 = simplib::to_integer('-1')
          $var2 = simplib::to_integer('24')

          simplib::inspect('var1', 'oneline_json')
          simplib::inspect('var2', 'oneline_json')
        EOS
      end

      it 'returns an integer' do
        results = apply_manifest_on(server, manifest)

        expect(results.output).to match(%r{Notice: Type => (Fixnum|Integer) Content => -1})
        expect(results.output).to match(%r{Notice: Type => (Fixnum|Integer) Content => 24})
      end
    end
  end
end
