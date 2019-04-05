require 'spec_helper_acceptance'

test_name 'ipaddresses function'

describe 'ipaddresses function' do

  servers = hosts_with_role(hosts, 'server')
  servers.each do |server|
    let(:all_ips) do
      ifaces = fact_on(server, 'interfaces').split(',').map(&:strip)

      ipaddresses = []

      ifaces.each do |iface|
        ipaddress = fact_on(server, "ipaddress_#{iface}")

        if ipaddress && !ipaddress.strip.empty?
          ipaddresses << ipaddress
        end
      end

      ipaddresses
    end

    let(:remote_ips) do
      retval = all_ips.dup

      retval.delete_if do |ip|
        ip =~ /^127\./
      end

      retval
    end

    context "when ipaddresses called with/without arguments" do
      let (:manifest) {
        <<-EOS
        $var1 = ipaddresses()
        $var2 = ipaddresses(true)

        simplib::inspect('var1')
        simplib::inspect('var2')
        EOS
      }

      it 'should return IP addresses and log a single deprecation warning' do
        results = apply_manifest_on(server, manifest).output.lines.map(&:strip)

        ip_matches = all_ips.map do |ip|
          results.grep(Regexp.new(Regexp.escape(ip)))
        end.flatten.compact

        expect(ip_matches).to_not be_empty

        expect(results.grep(/ipaddresses is deprecated, please use simplib::ipaddresses/).size).to eq 1
      end
    end

    context "when simplib::ipaddresses called with/without arguments" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::ipaddresses()
        $var2 = simplib::ipaddresses(true)

        simplib::inspect('var1')
        simplib::inspect('var2')
        EOS
      }

      it 'should return IP addresses without logging a deprecation warning' do
        results = apply_manifest_on(server, manifest).output.lines.map(&:strip)

        ip_matches = all_ips.map do |ip|
          results.grep(Regexp.new(Regexp.escape(ip)))
        end.flatten.compact

        expect(ip_matches).to_not be_empty

        expect(results.grep(/ipaddresses is deprecated, please use simplib::ipaddresses/)).to be_empty
      end
    end
  end
end
