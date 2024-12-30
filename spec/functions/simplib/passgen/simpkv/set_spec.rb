#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::simpkv::set' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'my_id' }
  let(:key) { "#{key_root_dir}/#{id}" }
  let(:password) { 'password for my_id' }
  let(:salt) { 'salt for my_id' }
  let(:complexity) { 0 }
  let(:complex_only) { false }

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
    it 'stores a new password' do
      is_expected.to run.with_params(id, password, salt, complexity, complex_only)

      # retrieve what has been stored by simpkv and validate
      stored_info = call_function('simpkv::get', key)
      expect(stored_info['value']['password']).to eq password
      expect(stored_info['value']['salt']).to eq salt
      expected_meta = {
        'complexity' => complexity,
        'complex_only' => complex_only,
        'history' => [],
      }
      expect(stored_info['metadata']).to eq(expected_meta)
    end

    it 'retains the history of the last 10 passwords with their salts' do
      expected_history = []
      (1..12).each do |run|
        rpassword = "#{password} run #{run}"
        rsalt = "#{salt} run #{run}"
        subject.execute(id, rpassword, rsalt, complexity, complex_only) # rubocop:disable RSpec/NamedSubject
        expected_history << [rpassword, rsalt]
      end

      # remove the current value and the oldest value and then reverse
      current_password, current_salt = expected_history.pop
      expected_history.delete_at(0)
      expected_history.reverse!

      # retrieve what has been stored by simpkv and validate
      stored_info = call_function('simpkv::get', key)
      expect(stored_info['value']['password']).to eq current_password
      expect(stored_info['value']['salt']).to eq current_salt
      expected_meta = {
        'complexity' => complexity,
        'complex_only' => complex_only,
        'history' => expected_history,
      }
      expect(stored_info['metadata']).to eq(expected_meta)
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

      is_expected.to run.with_params(
          id, password, salt, complexity, complex_only, simpkv_options
        ).and_raise_error(ArgumentError,
        %r{simpkv Configuration Error})
    end
  end
end
