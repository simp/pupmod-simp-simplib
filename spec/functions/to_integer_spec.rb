#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:to_integer) do
  let(:scope) do
    PuppetlabsSpec::PuppetInternals.scope
  end

  subject do
    function_name = Puppet::Parser::Functions.function(:to_integer)
    scope.method(function_name)
  end

  it 'should run successfully' do
    expect {
      expect(subject.call([12])).to be == 12
      expect(subject.call([12])).to_not be == '12'

      expect(subject.call(['12'])).to be == 12
      expect(subject.call(['12'])).to_not be == '12'
    }.not_to raise_error
  end
end
