require 'spec_helper'

describe 'simplib::debug::classtrace' do
  let(:pre_condition) do
    <<~END
      class foo { simplib::debug::classtrace() }

      define bar { include foo }

      class baz { bar { 'test': } }

      include baz
    END
  end

  it {
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Classtrace:\n    => Class[main]\n    => Class[Baz]\n    => Bar[test]\n    => Class[Foo])).once

    retval = scope.call_function('simplib::debug::classtrace', false)

    expect(retval).to eq(['Class[main]'])
  }
end
