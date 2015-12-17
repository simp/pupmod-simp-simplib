require 'spec_helper'

describe 'simplib::sysctl' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

      context "base" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('simplib::sysctl') }
      end

      context "with enable_ipv6 = false" do
        let(:params) {{ :enable_ipv6 => false }}
        it { is_expected.to create_sysctl__value('net.ipv6.conf.all.disable_ipv6').with(:value => '1') }
      end

      context "with enable_ipv6 = true and ipv6_enable = false" do
        new_facts = facts.dup
        new_facts[:ipv6_enabled => false]
        let(:facts) { new_facts }
        it { is_expected.to create_sysctl__value('net.ipv6.conf.all.disable_ipv6').with(:value => '0') }
      end

      context "kernel__core_pattern with absolute path" do
        let(:params) {{
          :kernel__core_pattern => '/foo/bar/baz'
        }}
        it { is_expected.to compile.with_all_deps }
      end

      context "kernel__core_pattern with non-aboslute path" do
        let(:params) {{
          :kernel__core_pattern => 'foo'
        }}
        it { is_expected.to compile.with_all_deps }
      end

      context "kernel__core_pattern with pipe and absolute path" do
        let(:params) {{
          :kernel__core_pattern => '| /bin/foo'
        }}
        it { is_expected.to compile.with_all_deps }
      end

      context "kernel__core_pattern with pipe and non-absolute path" do
        let(:params) {{
          :kernel__core_pattern => '| bin/foo'
        }}
        it {
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(/Piped commands for kernel.core_pattern must have an absolute path/)
        }
      end

      context "kernel__core_pattern with over 128 characters" do
        let(:params) {{
          :kernel__core_pattern => ('a'*129)
        }}
        it {
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(/must be less than 129 characters/)
        }
      end
    end
  end
end
