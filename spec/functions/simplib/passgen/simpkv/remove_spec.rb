#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::simpkv::remove' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'my_id' }
  let(:key) { "#{key_root_dir}/#{id}" }

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
    call_function('simpkv::deletetree', key_root_dir)
  end

  context 'successful operation' do
    it 'succeeds when password key does not exist' do
      is_expected.to run.with_params(id)
    end

    it 'removes password key when it exists' do
      # call subject() to make sure test Puppet environment is created
      # before we try to pre-populate the default key/value store with
      # a password
      subject # rubocop:disable RSpec/NamedSubject
      value = { 'password' => 'the password', 'salt' => 'the salt' }
      meta = {
        'complexity' => 0,
        'complex_only' => false,
        'history' => [],
      }
      call_function('simpkv::put', key, value, meta)

      is_expected.to run.with_params(id)
      expect(call_function('simpkv::exists', key)).to be false
    end
  end

  context 'failures' do
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

      is_expected.to run.with_params(id, simpkv_options)
                        .and_raise_error(ArgumentError, %r{simpkv Configuration Error})
    end
  end
end
