require 'spec_helper_acceptance'

test_name 'inspect function'

def normalize(puppet_log)
  # remove normal puppet log lines and inspect/simplib::inspect
  # 'puts' lines, as their ordering relative to the Puppet warning
  # lines is non-deterministic
  normalized_lines = puppet_log.split("\n").delete_if do |line|
    line.include?('Loading facts') or
    line.include?('Compiled catalog for') or
    line.include?('Applying configuration version') or
    line.include?('Applied catalog in') or
    line.match(/^Inspect:/)
  end


  normalized_log = normalized_lines.join("\n")
  # remove color formatting
  yellow_bold_fmt_begin = "\e[1;33m"
  fmt_clear = "\e[0m"
  bad_fmt = "\e[m"  # used at the beginning of Notice lines
  normalized_log.gsub!(yellow_bold_fmt_begin, '')
  normalized_log.gsub!(fmt_clear, '')
  normalized_log.gsub!(bad_fmt, '')
  normalized_log + "\n"
end

describe 'inspect function' do
  let(:opts) do
    {:environment=> {'SIMPLIB_LOG_DEPRECATIONS' => 'true'}}
  end

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    context "logs variables with deprecated inspect" do
      let (:manifest) {
        <<-EOS
        $var1 = "var1 value"
        $var2 = true
        $var3 = { 'a' => 'b'}
        $var4 = undef

        inspect($var1)
        inspect($var2)
        inspect($var3)
        inspect($var4)
        EOS
      }

      it 'should be able to log variables with a single deprecation warning' do
        results = apply_manifest_on(server, manifest, opts)

        expected = %r|Warning: inspect is deprecated, please use simplib::inspect
\s+\(at /etc/puppetlabs/code/environments/production/modules/simplib/lib/puppet/parser/functions/simplib_deprecation\.rb:\d+:in `block in <module:Functions>'\)
Warning: Inspect: Type => 'String' Content => '"var1 value"'
Warning: Inspect: Type => 'TrueClass' Content => 'true'
Warning: Inspect: Type => 'Hash' Content => '\{"a":"b"\}'
Warning: Inspect: Type => 'String' Content => '""'|

        expect(normalize(results.output)).to match(expected)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('inspect is deprecated, please use simplib::inspect')
        end

        expect(deprecation_lines.size).to eq 1
      end
    end

    context "logs variables with simplib::inspect" do
      let (:manifest) {
        <<-EOS
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

      it 'should be log variables without any deprecation warnings' do
        results = apply_manifest_on(server, manifest, opts)

        output = results.output

        # this is ugly, but is logged twice
        expected = <<EOM
Notice: Type => String Content => "var1 value"
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var1]/message: defined 'message' as 'Type => String Content => "var1 value"'
Notice: Type => TrueClass Content => true
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var2]/message: defined 'message' as 'Type => TrueClass Content => true'
Notice: Type => Hash Content => {"a":"b"}
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var3]/message: defined 'message' as 'Type => Hash Content => {"a":"b"}'
Notice: Type => NilClass Content => null
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var4]/message: defined 'message' as 'Type => NilClass Content => null'
EOM

puts '<'*80
puts normalize(results.output).inspect
puts '>'*80

        expect(normalize(results.output)).to eq(expected)

        deprecation_lines = results.output.split("\n").delete_if do |line|
          !line.include?('inspect is deprecated, please use simplib::inspect')
        end

        expect(deprecation_lines.size).to eq 0
      end
    end
  end
end
