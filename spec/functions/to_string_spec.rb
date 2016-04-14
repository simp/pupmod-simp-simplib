#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'to_string' do
  it 'should run successfully' do
    expect {
      expect(subject.call(['12'])).to be == '12'
      expect(subject.call(['12'])).to_not be == 12

      expect(subject.call([12])).to be == '12'
      expect(subject.call([12])).to_not be == 12
    }.not_to raise_error
  end
end
