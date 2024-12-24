#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::lookup' do
  let(:pre_condition) do
    <<~END
      $global_var = 'global'

      class test::class (
        $param1 = 'foo'
      ) {
        $internal_param = 'bar'

        notify { $param1: }
      }

      include 'test::class'
    END
  end

  it 'runs successfully' do
    is_expected.to run.with_params('test::class::param1').and_return('foo')
  end

  it 'looks up a global variable when it is present' do
    is_expected.to run.with_params('global_var').and_return('global')
  end

  it 'does not look up a variable when it is inside class scope' do
    is_expected.to run.with_params('test_class::internal_param').and_raise_error(
      Puppet::DataBinding::LookupError,
      %r{did not find a value for.*test_class::internal_param.*},
    )
  end

  it 'fails via lookup() when trying to find an unknown value' do
    is_expected.to run.with_params('what_is_this').and_raise_error(
      Puppet::DataBinding::LookupError,
      %r{did not find a value for.*what_is_this.*},
    )
  end
end
