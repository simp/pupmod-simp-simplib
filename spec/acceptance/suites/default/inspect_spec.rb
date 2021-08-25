require 'spec_helper_acceptance'

test_name 'simplib::inspect function'

describe 'simplib::inspect function' do

  # Only return simplib::inspect lines from the Puppet log minus any ANSI
  # escape sequences for formatting (e.g. color).
  #
  # NOTE: Have to remove ANSI formatting because beaker does not provide a
  # mechanism to enable the `--color=false` option on `puppet apply`.
  def normalize_inspect_lines(puppet_log)
    normalized_lines = puppet_log.gsub(/\e\[\d*(;\d+)*m/, "").split("\n").select do |line|
      line.match(/^Notice: .*Type =>/)
    end

    normalized_lines.join("\n")
  end

  hosts.each do |server|
    context "logs variables with simplib::inspect on #{server}" do
      let (:manifest) {
        <<~EOS
          $var1 = "var1 value"
          $var2 = true
          $var3 = { 'a' => 'b'}
          $var4 = undef

          simplib::inspect('var1', 'oneline_json')
          simplib::inspect('var2', 'oneline_json')
          simplib::inspect('var3', 'oneline_json')
          simplib::inspect('var4', 'oneline_json')
        EOS
      }

      it 'should be log variables' do
        results = apply_manifest_on(server, manifest)
        output = results.output

        # this is ugly, but is logged twice
        expected = <<~EOM
          Notice: Type => String Content => "var1 value"
          Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var1]/message: defined 'message' as 'Type => String Content => "var1 value"'
          Notice: Type => TrueClass Content => true
          Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var2]/message: defined 'message' as 'Type => TrueClass Content => true'
          Notice: Type => Hash Content => {"a":"b"}
          Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var3]/message: defined 'message' as 'Type => Hash Content => {"a":"b"}'
          Notice: Type => NilClass Content => null
          Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var4]/message: defined 'message' as 'Type => NilClass Content => null'
        EOM

        expect(normalize_inspect_lines(results.output)).to eq(expected.chomp)
      end
    end
  end
end
