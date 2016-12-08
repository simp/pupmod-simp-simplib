#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::lookup' do
  let(:pre_condition){%{
    class test::class (
      $param1 = 'foo'
     ) {
       notify { $param1: }
     }

     include 'test::class'
  }}

  it 'should run successfully' do
    is_expected.to run.with_params('test::class::param1')
  end

  it 'should fail via lookup() when trying to find an unknown value' do
    is_expected.to run.with_params('what_is_this').and_raise_error(
      Puppet::DataBinding::LookupError,
      /did not find a value for.*what_is_this.*/
    )
  end
end
