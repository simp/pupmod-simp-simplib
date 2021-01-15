require 'spec_helper'

describe 'simplib::debug::stacktrace' do
  let(:pre_condition) {%{
    class foo { simplib::debug::stacktrace() }

    define bar { include foo }

    class baz { bar { 'test': } }

    include baz
  }}

  it {
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Stacktrace:\n    => unknown:2\n    => unknown:4))

    retval = scope.call_function('simplib::debug::stacktrace', false)

    # Topscope gets nothing
    expect(retval).to eq([])
  }
end
