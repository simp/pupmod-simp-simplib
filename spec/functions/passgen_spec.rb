#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'passgen' do
  let(:default_chars) do
    (("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a).map do|x|
      x = Regexp.escape(x)
    end
  end

  let(:safe_special_chars) do
    ['@','%','-','_','+','=','~'].map do |x|
      x = Regexp.escape(x)
    end
  end

  let(:unsafe_special_chars) do
    (((' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a)).map do |x|
      x = Regexp.escape(x)
    end - safe_special_chars
  end

  it 'should run successfully with default arguments' do
    expect { run.with_params(['spectest']) }.to_not raise_error
  end

  it 'should return a password that is 32 alphanumeric characters long by default' do
    result = subject.call(['spectest'])
    expect(result.length).to eql(32)
    expect(result).to match(/^(#{default_chars.join('|')})+$/)
  end

  it 'should work with a String length' do
    result = subject.call([ 'spectest', {'length' => '32'} ])
    expect(result.length).to eql(32)
    expect(result).to match(/^(#{default_chars.join('|')})+$/)
  end

  it 'should return a password that is 8 alphanumeric characters long if length is 8' do
    result = subject.call([ 'spectest', {'length' => 8} ])
    expect(result.length).to eql(8)
    expect(result).to match(/^(#{default_chars.join('|')})+$/)
  end

  it 'should return a password that contains "safe" special characters if complexity is 1' do
    result = subject.call([ 'spectest', {'complexity' => 1} ])
    expect(result.length).to eql(32)
    expect(result).to match(/(#{default_chars.join('|')})/)
    expect(result).to match(/(#{(safe_special_chars).join('|')})/)
    expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)
  end

  it 'should work with a String complexity' do
    result = subject.call([ 'spectest', {'complexity' => '1'} ])
    expect(result.length).to eql(32)
    expect(result).to match(/(#{default_chars.join('|')})/)
    expect(result).to match(/(#{(safe_special_chars).join('|')})/)
    expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)
  end

  it 'should return a password that contains all special characters if complexity is 2' do
    result = subject.call([ 'spectest', {'complexity' => 2} ])
    expect(result.length).to eql(32)
    expect(result).to match(/(#{default_chars.join('|')})/)
    expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)
  end

  it 'should return the next to last created password if "last" is true' do
    first_result = subject.call([ 'spectest', {'length' => 32} ])
    second_result = subject.call([ 'spectest', {'length' => 33} ])
    third_result = subject.call([ 'spectest', {'length' => 34} ])
    expect(subject.call([ 'spectest', 'last' ])).to eql(second_result)
  end

  it 'should return the current password if "last" is true but there is no previous password' do
    result = subject.call([ 'spectest', {'length' => 32} ])
    expect(subject.call([ 'spectest', 'last' ])).to eql(result)
  end

  it 'should return an md5 hash of the password if passed "md5"' do
    result = subject.call([ 'spectest', {'hash' => 'md5'} ])
    expect(result).to match(/^\$1\$/)
  end

  it 'should return an sha256 hash of the password if passed "sha256"' do
    result = subject.call([ 'spectest', {'hash' => 'sha256'} ])
    expect(result).to match(/^\$5\$/)
  end

  it 'should return an sha512 hash of the password if passed "sha512"' do
    result = subject.call([ 'spectest', {'hash' => 'sha512'} ])
    expect(result).to match(/^\$6\$/)
  end

  ## Legacy Options
  it 'should return the next to last created password if the second argument is "last"' do
    first_result = subject.call([ 'spectest' ])
    second_result = subject.call([ 'spectest', 33 ])
    expect(subject.call([ 'spectest', 'last' ])).to eql(first_result)
  end

  it 'should return a password of length 8 if the second argument is "8"' do
    result = subject.call([ 'spectest' ])
    expect(subject.call([ 'spectest', 8 ]).length).to eql(8)
  end
end
