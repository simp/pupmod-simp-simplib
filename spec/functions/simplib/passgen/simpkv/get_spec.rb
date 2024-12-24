#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::simpkv::get' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'my_id' }
  let(:key) { "#{key_root_dir}/#{id}" }
  let(:password) { 'password for my_id 2' }
  let(:salt) { 'salt for my_id 2' }
  let(:complexity) { 0 }
  let(:complex_only) { false }
  let(:history) do
    [
      [ 'password for my_id 1', 'salt for my_id 1'],
      [ 'password for my_id 0', 'salt for my_id 0'],
    ]
  end

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
    it 'returns {} when the password does not exist' do
      is_expected.to run.with_params(id).and_return({})
    end

    it 'returns a stored password' do
      # call subject() to make sure test Puppet environment is created
      # before we try to pre-populate the default key/value store with
      # a password
      subject # rubocop:disable RSpec/NamedSubject
      value = { 'password' => password, 'salt' => salt }
      meta = {
        'complexity'   => complexity,
        'complex_only' => complex_only,
        'history'      => history
      }
      call_function('simpkv::put', key, value, meta)

      expected = { 'value' => value, 'metadata' => meta }
      is_expected.to run.with_params(id).and_return(expected)
    end
  end

  context 'failures' do
    it 'fails when returned info is incomplete' do
      subject # rubocop:disable RSpec/NamedSubject
      value = { 'salt' => salt }
      meta = {
        'complexity'   => complexity,
        'complex_only' => complex_only,
        'history'      => history
      }
      call_function('simpkv::put', key, value, meta)

      is_expected.to run.with_params(id).and_raise_error(RuntimeError,
        %r{Malformed password info retrieved for 'my_id'})
    end

    it 'fails when simpkv operation fails' do
      simpkv_options = {
        'backend'  => 'oops',
        'backends' => {
          'oops' => {
            'type' => 'does_not_exist_type',
            'id'   => 'test',
          }
        }
      }

      is_expected.to run.with_params(id, simpkv_options)
                        .and_raise_error(ArgumentError,
        %r{simpkv Configuration Error})
    end
  end
end
