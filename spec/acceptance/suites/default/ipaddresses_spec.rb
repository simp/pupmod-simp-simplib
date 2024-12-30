require 'spec_helper_acceptance'

test_name 'simplib::ipaddresses function'

describe 'simplib::ipaddresses function' do
  hosts.each do |server|
    let(:all_ips) do
      fact_on(server, 'networking.interfaces')
        .select { |_, v| v['ip'].is_a?(String) && !v['ip'].empty? }
        .map { |_, v| v['ip'] }
    end

    let(:remote_ips) do
      retval = all_ips.dup

      retval.delete_if do |ip|
        ip =~ %r{^127\.}
      end

      retval
    end

    context "when simplib::ipaddresses called with/without arguments on #{server}" do
      let(:manifest) do
        <<~EOS
          $var1 = simplib::ipaddresses()
          $var2 = simplib::ipaddresses(true)

          simplib::inspect('var1')
          simplib::inspect('var2')
        EOS
      end

      it 'returns IP addresses' do
        results = apply_manifest_on(server, manifest).output.lines.map(&:strip)

        ip_matches = all_ips.map { |ip|
          results.grep(Regexp.new(Regexp.escape(ip)))
        }.flatten.compact

        expect(ip_matches).not_to be_empty
      end
    end
  end
end
