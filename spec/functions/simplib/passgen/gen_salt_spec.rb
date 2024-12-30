#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::gen_salt' do
  let(:default_chars) do
    (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).map do |x|
      Regexp.escape(x)
    end
  end

  let(:safe_special_chars) do
    ['@', '%', '-', '_', '+', '=', '~'].map do |x|
      Regexp.escape(x)
    end
  end

  let(:unsafe_special_chars) do
    (((' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a)).map { |x|
      Regexp.escape(x)
    } - safe_special_chars
  end

  it 'returns salt with length 16 and complexity of 0 when default timeout_seconds is used' do
    salt = subject.execute # rubocop:disable RSpec/NamedSubject

    expect(salt.length).to be(16)
    expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
    expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
    expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})
  end

  it 'returns salt with length 16 and complexity of 0 when timeout_seconds is specified' do
    salt = subject.execute(15) # rubocop:disable RSpec/NamedSubject

    expect(salt.length).to be(16)
    expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
    expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
    expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})
  end

  it 'fails when salt generation times out' do
    expect(Timeout).to receive(:timeout).with(20).and_raise(Timeout::Error, 'Timeout')
    is_expected.to run.with_params(20).and_raise_error(Timeout::Error,
      'Timeout')
  end
end
