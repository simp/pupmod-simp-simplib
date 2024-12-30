require 'spec_helper'

describe 'simplib::debug::stacktrace' do
  let(:pre_condition) do
    <<~END
      class foo { simplib::debug::stacktrace() }

      define bar { include foo }

      class baz { bar { 'test': } }

      include baz
    END
  end

  it do
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Stacktrace:\n    => unknown:1\n    => unknown:3))

    retval = scope.call_function('simplib::debug::stacktrace', false)

    # Topscope gets nothing
    expect(retval).to eq([])
  end
end
