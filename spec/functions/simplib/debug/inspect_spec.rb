require 'spec_helper'

describe 'simplib::debug::inspect' do
  let(:pre_condition) {%{
    $foo = 'test_value'

    simplib::debug::inspect($foo)

    class test {
      $bar = 'other value'

      simplib::debug::inspect($bar)
    }

    include 'test'
  }}

  it {
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"test_value"' Scope: 'Scope(Class[main])'))
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"other value"' Location: ':6' Scope: 'Scope(Class[Test])'))
    expect(Puppet).to receive(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"foo"' Scope: 'Scope(Class[main])'))

    retval = scope.call_function('simplib::debug::inspect', 'foo')

    expect(retval).to eq({
      :type        => String,
      :content     => '"foo"',
      :module_name => '',
      :scope       => "Scope(Class[main])",
      :file        => nil,
      :line        => nil
    })
  }
end
