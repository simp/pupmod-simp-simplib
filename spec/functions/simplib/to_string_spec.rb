#!/usr/bin/env ruby -S rspec
require 'spec_helper'

class ClassWithoutToS
  undef_method :to_s
end

describe 'simplib::to_string' do
  context 'should return converted value when conversion is possible' do
    it { is_expected.to run.with_params('12').and_return('12') }
    it { is_expected.to run.with_params(12).and_return('12') }
    it { is_expected.to run.with_params(nil).and_return('') }

    # Perhaps unexpected behavior? If we don't want this, we need to
    # change the required_param type in the :to_string dispatch
    it { is_expected.to run.with_params([34, 56]).and_return('[34, 56]') }

    # Ruby 3.4 changed Hash#to_s/#inspect formatting from `{"tag"=>"value"}`
    # to `{"tag" => "value"}` (extra spaces around the hash rocket). Accept
    # either format since simplib::to_string() intentionally passes through
    # Ruby's native Hash#to_s.
    it { is_expected.to run.with_params({ 'tag' => 'value' }).and_return(%r{\A\{"tag"\s*=>\s*"value"\}\z}) }
  end

  context 'should fail when conversion is not possible' do
    let(:odd_var) { ClassWithoutToS.new }

    it { is_expected.to run.with_params(odd_var).and_raise_error(%r{cannot be converted to a String}) }
  end
end
