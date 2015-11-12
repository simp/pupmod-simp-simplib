require 'spec_helper'

describe 'simplib::sysctl' do

  it { should compile.with_all_deps }

  context "kernel__core_pattern with absolute path" do
    let(:params) {{
      :kernel__core_pattern => '/foo/bar/baz'
    }}
    it { should compile.with_all_deps }
  end

  context "kernel__core_pattern with non-aboslute path" do
    let(:params) {{
      :kernel__core_pattern => 'foo'
    }}
    it { should compile.with_all_deps }
  end

  context "kernel__core_pattern with pipe and absolute path" do
    let(:params) {{
      :kernel__core_pattern => '| /bin/foo'
    }}
    it { should compile.with_all_deps }
  end

  context "kernel__core_pattern with pipe and non-absolute path" do
    let(:params) {{
      :kernel__core_pattern => '| bin/foo'
    }}
    it {
      expect {
        should compile.with_all_deps
      }.to raise_error(/Piped commands for kernel.core_pattern must have an absolute path/)
    }
  end

  context "kernel__core_pattern with over 128 characters" do
    let(:params) {{
      :kernel__core_pattern => ('a'*129)
    }}
    it {
      expect {
        should compile.with_all_deps
      }.to raise_error(/must be less than 129 characters/)
    }
  end
end
