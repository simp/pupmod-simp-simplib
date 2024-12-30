#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen' do
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

  # The bulk of simplib::passgen testing is done in tests for
  # simplib::passgen::legacy::passgen and simplib::passgen::simpkv::passgen.
  # The primary focus of this test is to spot check that the correct
  # function is called and failures are appropriately reported.

  context 'legacy passgen' do
    # DEBUG NOTES:
    #   Puppet[:vardir] is dynamically created as a tmpdir by the test
    #   framework, when the subject is first created. So if you want
    #   to know what vardir is so you can create/modify files in
    #   that directory as part of the test setup, in the 'it' block,
    #   first create the subject yourself and then retrieve the
    #   vardir value as shown below:
    #
    # it 'does something' do
    #   subject()  # vardir created as a tmpdir for this example block
    #   vardir = Puppet[:vardir]
    #
    #   <pre-seed file content here>
    #
    #   is_expected.to run.with_params('spectest')  # run the function
    #
    # end
    context 'basic password generation' do
      it 'runs successfully with default arguments' do
        result = subject.execute('spectest') # rubocop:disable RSpec/NamedSubject

        vardir = Puppet[:vardir]
        passwd_file = File.join(vardir, 'simp', 'environments', 'rp_env', 'simp_autofiles', 'gen_passwd', 'spectest')
        expect(File.exist?(passwd_file)).to be true
        password = IO.read(passwd_file).chomp
        expect(password).to eq result

        salt_file = File.join(vardir, 'simp', 'environments', 'rp_env', 'simp_autofiles', 'gen_passwd', 'spectest.salt')
        expect(File.exist?(salt_file)).to be true
        salt = IO.read(salt_file).chomp
        expect(salt.length).to eq 16
        expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
      end

      it 'returns a password that is 8 alphanumeric characters long if length is 8' do
        result = subject.execute('spectest', { 'length' => 8 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(8)
        expect(result).to match(%r{^(#{default_chars.join('|')})+$})
      end

      it 'returns a password that contains "safe" special characters if complexity is 1' do
        result = subject.execute('spectest', { 'complexity' => 1 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
        expect(result).to match(%r{(#{default_chars.join('|')})})
        expect(result).to match(%r{(#{safe_special_chars.join('|')})})
        expect(result).not_to match(%r{(#{unsafe_special_chars.join('|')})})
      end

      it 'returns a password that contains all special characters if complexity is 2' do
        result = subject.execute('spectest', { 'complexity' => 2 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
        expect(result).to match(%r{(#{default_chars.join('|')})})
        expect(result).to match(%r{(#{unsafe_special_chars.join('|')})})
      end
    end

    context 'password generation with history' do
      it 'returns the same password when called multiple times with same options' do
        first_result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'length' => 32 })).to eq(first_result) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'length' => 32 })).to eq(first_result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns current password if no password options are specified' do
        result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest')).to eql(result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns a new password if previous password has different specified length' do
        first_result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        second_result = subject.execute('spectest', { 'length' => 64 }) # rubocop:disable RSpec/NamedSubject
        expect(second_result).not_to eq(first_result)
        expect(second_result.length).to eq(64)
      end

      it 'returns the next to last created password if "last" is true' do
        subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        second_result = subject.execute('spectest', { 'length' => 33 }) # rubocop:disable RSpec/NamedSubject
        subject.execute('spectest', { 'length' => 34 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'last' => true })).to eql(second_result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns the current password if "last" is true but there is no previous password' do
        result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'last' => true })).to eql(result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns a new password if "last" is true but there is no current or previous password' do
        result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
      end
    end

    context 'misc errors' do
      it 'fails when keydir cannot be created' do
        skip("Test can't be run as root") if (ENV['USER'] == 'root') || (ENV['HOME'] == '/root')

        subject # rubocop:disable RSpec/NamedSubject
        vardir = Puppet[:vardir]
        autofiles_dir = File.join(vardir, 'simp', 'environments', 'rp_env', 'simp_autofiles')
        FileUtils.mkdir_p(autofiles_dir)
        FileUtils.chmod(0o550, autofiles_dir)
        is_expected.to run.with_params('spectest').and_raise_error(
          %r{simplib::passgen: Could not make directory},
        )

        # cleanup so directory can be removed when tmpdir is destroyed
        FileUtils.chmod(0o750, autofiles_dir)
      end

      it do
        is_expected.to run.with_params('spectest', { 'length' => 'oops' }).and_raise_error(
          %r{Error: Length 'oops' must be an integer},
        )
      end

      it do
        is_expected.to run.with_params('spectest', { 'complexity' => 'oops' }).and_raise_error(
          %r{Error: Complexity 'oops' must be an integer},
        )
      end

      it do
        is_expected.to run.with_params('spectest', { 'gen_timeout_seconds' => 'oops' }).and_raise_error(
          %r{Error: Password generation timeout 'oops' must be an integer},
        )
      end

      it do
        is_expected.to run.with_params('spectest', { 'hash' => 'sha1' }).and_raise_error(
          %r{Error: 'sha1' is not a valid hash},
        )
      end
    end
  end

  context 'simpkv passgen' do
    let(:hieradata) { 'simplib_passgen_simpkv' }

    after(:each) do
      # This is required for GitLab, because the spec tests are run by a
      # privileged user who ends up creating a global file store in
      # /var/simp/simpkv/file/auto_default, instead of a set of per-test,
      # temporary file stores, each within its test-specific Puppet
      # environment.
      #
      # If we wanted to be truly safe from privileged user issues, we would
      # either configure simpkv to use the file plugin with an appropriate
      # per-test path, or, convert all the unit test to use rspec-mocks
      # instead of mocha and then use an appropriate pair of
      # `allow(FileUtils).to receive(:mkdir_p).with...` that fail the global
      # file store directory creation but allow other directory creations.
      # (See spec tests in pupmod-simp-simpkv).
      #
      call_function('simpkv::deletetree', 'gen_passwd')
    end

    context 'basic password generation' do
      it 'runs successfully with default arguments' do
        result = subject.execute('spectest') # rubocop:disable RSpec/NamedSubject
        expect(result.length).to eq 32
        expect(result).to match(%r{^(#{default_chars.join('|')})+$})

        # retrieve what has been stored by simpkv and validate
        stored_info = call_function('simpkv::get', 'gen_passwd/spectest')
        expect(stored_info['value']['password']).to eq result
        salt = stored_info['value']['salt']
        expect(salt.length).to eq 16
        expect(salt).to match(%r{^(#{default_chars.join('|')})+$})
        meta = { 'complexity' => 0, 'complex_only' => false, 'history' => [] }
        expect(stored_info['metadata']).to eq(meta)
      end

      it 'returns a password that is 8 alphanumeric characters long if length is 8' do
        result = subject.execute('spectest', { 'length' => 8 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(8)
        expect(result).to match(%r{^(#{default_chars.join('|')})+$})
      end

      it 'returns a password that contains "safe" special characters if complexity is 1' do
        result = subject.execute('spectest', { 'complexity' => 1 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
        expect(result).to match(%r{(#{default_chars.join('|')})})
        expect(result).to match(%r{(#{safe_special_chars.join('|')})})
        expect(result).not_to match(%r{(#{unsafe_special_chars.join('|')})})

        # retrieve what has been stored by simpkv and validate metadata
        stored_info = call_function('simpkv::get', 'gen_passwd/spectest')
        meta = { 'complexity' => 1, 'complex_only' => false, 'history' => [] }
        expect(stored_info['metadata']).to eq(meta)
      end

      it 'returns a password that contains all special characters if complexity is 2' do
        result = subject.execute('spectest', { 'complexity' => 2 }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
        expect(result).to match(%r{(#{default_chars.join('|')})})
        expect(result).to match(%r{(#{unsafe_special_chars.join('|')})})

        # retrieve what has been stored by simpkv and validate metadata
        stored_info = call_function('simpkv::get', 'gen_passwd/spectest')
        meta = { 'complexity' => 2, 'complex_only' => false, 'history' => [] }
        expect(stored_info['metadata']).to eq(meta)
      end
    end

    context 'password generation with history' do
      it 'returns the same password when called multiple times with same options' do
        first_result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'length' => 32 })).to eq(first_result) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'length' => 32 })).to eq(first_result) # rubocop:disable RSpec/NamedSubject
        stored_info = call_function('simpkv::get', 'gen_passwd/spectest')
        expect(stored_info['metadata']['history']).to be_empty
      end

      it 'returns current password if no password options are specified' do
        # intentionally pick a password with a length different than default length
        result = subject.execute('spectest', { 'length' => 64 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest')).to eql(result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns a new password if previous password has different specified length' do
        first_result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        second_result = subject.execute('spectest', { 'length' => 64 }) # rubocop:disable RSpec/NamedSubject
        expect(second_result).not_to eq(first_result)
        expect(second_result.length).to eq(64)
      end

      it 'returns a new password if previous password has different specified complexity' do
        first_result = subject.execute('spectest', { 'complexity' => 0 }) # rubocop:disable RSpec/NamedSubject
        second_result = subject.execute('spectest', { 'complexity' => 1 }) # rubocop:disable RSpec/NamedSubject
        expect(second_result).not_to eq(first_result)
      end

      it 'returns the next to last created password if "last" is true' do
        subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        # changing password length forces a new password to be generated
        second_result = subject.execute('spectest', { 'length' => 33 }) # rubocop:disable RSpec/NamedSubject
        subject.execute('spectest', { 'length' => 34 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'last' => true })).to eql(second_result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns the current password if "last" is true but there is no previous password' do
        result = subject.execute('spectest', { 'length' => 32 }) # rubocop:disable RSpec/NamedSubject
        expect(subject.execute('spectest', { 'last' => true })).to eql(result) # rubocop:disable RSpec/NamedSubject
      end

      it 'returns a new password if "last" is true but there is no current or previous password' do
        result = subject.execute('spectest', { 'last' => true }) # rubocop:disable RSpec/NamedSubject
        expect(result.length).to be(32)
      end
    end

    context 'misc errors' do
      it 'fails when simpkv operation fails' do
        simpkv_options = {
          'backend'  => 'oops',
          'backends' => {
            'oops' => {
              'type' => 'does_not_exist_type',
              'id'   => 'test',
            },
          },
        }

        is_expected.to run.with_params('spectest', {}, simpkv_options)
                          .and_raise_error(ArgumentError, %r{simpkv Configuration Error})
      end

      it do
        is_expected.to run.with_params('spectest', { 'length' => 'oops' }).and_raise_error(
          %r{Error: Length 'oops' must be an integer},
        )
      end

      it do
        is_expected.to run.with_params('spectest', { 'complexity' => 'oops' }).and_raise_error(
        %r{Error: Complexity 'oops' must be an integer},
      )
      end

      it do
        is_expected.to run.with_params('spectest', { 'gen_timeout_seconds' => 'oops' }).and_raise_error(
          %r{Error: Password generation timeout 'oops' must be an integer},
        )
      end

      it do
        is_expected.to run.with_params('spectest', { 'hash' => 'sha1' }).and_raise_error(
          %r{Error: 'sha1' is not a valid hash},
        )
      end
    end
  end
end
