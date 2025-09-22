#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::gen_password_and_salt' do
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
    ((' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a).map { |x|
      Regexp.escape(x)
    } - safe_special_chars
  end

  context 'successes' do
    it 'returns appropriate salt and a password that contains default characters if complexity is 0' do
      password, salt = subject.execute(48, 0, false, 30) # rubocop:disable RSpec/NamedSubject

      expect(salt.length).to be(16)
      expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})

      expect(password.length).to be(48)
      expect(password).to match(%r{^(#{default_chars.join('|')})+$})
      expect(password).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(password).not_to match(%r{(#{unsafe_special_chars.join('|')})})
    end

    it 'returns appropriate salt and a password that contains "safe" special characters if complexity is 1' do
      password, salt = subject.execute(128, 1, false, 30) # rubocop:disable RSpec/NamedSubject

      expect(salt.length).to be(16)
      expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})

      expect(password.length).to be(128)
      expect(password).to match(%r{(#{default_chars.join('|')})})
      expect(password).to match(%r{(#{safe_special_chars.join('|')})})
      expect(password).not_to match(%r{(#{unsafe_special_chars.join('|')})})
    end

    it 'returns appropriate salt and a password that only contains "safe" special characters if complexity is 1 and complex_only is true' do
      password, salt = subject.execute(128, 1, true, 30) # rubocop:disable RSpec/NamedSubject

      expect(salt.length).to be(16)
      expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})

      expect(password.length).to be(128)
      expect(password).not_to match(%r{(#{default_chars.join('|')})})
      expect(password).to match(%r{(#{safe_special_chars.join('|')})})
      expect(password).not_to match(%r{(#{unsafe_special_chars.join('|')})})
    end

    it 'returns appropriate salt and a password that contains all special characters if complexity is 2' do
      password, salt = subject.execute(128, 2, false, 30) # rubocop:disable RSpec/NamedSubject

      expect(salt.length).to be(16)
      expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})

      expect(password.length).to be(128)
      expect(password).to match(%r{(#{default_chars.join('|')})})
      expect(password).to match(%r{(#{safe_special_chars.join('|')})})
      expect(password).to match(%r{(#{unsafe_special_chars.join('|')})})
    end

    it 'returns appropriate salt and a password that only contains all special characters if complexity is 2 and complex_only is true' do
      password, salt = subject.execute(128, 2, true, 30) # rubocop:disable RSpec/NamedSubject

      expect(salt.length).to be(16)
      expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      expect(salt).not_to match(%r{(#{safe_special_chars.join('|')})})
      expect(salt).not_to match(%r{(#{unsafe_special_chars.join('|')})})

      expect(password.length).to be(128)
      expect(password).not_to match(%r{(#{default_chars.join('|')})})
      expect(password).to match match(%r{(#{safe_special_chars.join('|')})})
      expect(password).to match(%r{(#{unsafe_special_chars.join('|')})})
    end
  end

  context 'errors' do
    it 'fails when password generation times out' do
      expect(Timeout).to receive(:timeout).with(30).and_raise(Timeout::Error, 'Timeout')
      is_expected.to run.with_params(16, 0, false, 30).and_raise_error(Timeout::Error,
        'Timeout')
    end
  end
end
