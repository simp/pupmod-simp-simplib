#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::list' do
  let(:id) { 'my_id' }
  let(:password) { 'password for my_id' }
  let(:salt) { 'salt for my_id' }

  # The bulk of simplib::passgen::list testing is done in tests for
  # simplib::passgen::legacy::list and simplib::passgen::simpkv::list.
  # The  primary focus of this test is to spot check that the correct
  # function is called and failures are appropriately reported.

  context 'legacy passgen::list' do
    ##############################################

    context 'successes' do
      it 'returns {} when the root folder does not exist' do
        is_expected.to run.with_params.and_return({})
      end

      it 'returns empty password and folder results when the root folder is empty' do
        # call subject() to make sure test Puppet environment is created
        subject # rubocop:disable RSpec/NamedSubject
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])

        expected = { 'keys' => {}, 'folders' => [] }
        is_expected.to run.with_params.and_return(expected)
      end

      it 'returns password info and folders when root folder is not empty' do
        subject # rubocop:disable RSpec/NamedSubject
        call_function('simplib::passgen::legacy::set', id, password, salt)

        expected = {
          'keys' => {
            id => {
              'value'    => { 'password' => password, 'salt' => salt },
              'metadata' => { 'history' => [] }
            }
          },
          'folders' => []
        }

        is_expected.to run.with_params.and_return(expected)
      end
    end

    context 'failures' do
      it 'fails when the password root directory cannot be accessed' do
        subject # rubocop:disable RSpec/NamedSubject
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        expect(Dir).to receive(:chdir).with(settings['keydir'])
                                      .and_raise(Errno::EACCES, 'chdir failed')

        is_expected.to run.with_params.and_raise_error(Errno::EACCES,
          'Permission denied - chdir failed')
      end
    end
  end

  context 'simpkv passgen::list' do
    let(:hieradata) { 'simplib_passgen_simpkv' }

    let(:key_root_dir) { 'gen_passwd' }
    let(:sub_folder) { 'my/sub/folder' }

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

    context 'successes' do
      context 'root folder' do
        it 'returns {} when the root folder does not exist' do
          is_expected.to run.with_params.and_return({})
        end

        it 'returns empty password and folder results when the root folder is empty' do
          # call subject() to make sure test Puppet environment is created
          # before we try to pre-populate the default key/value store with
          # passwords
          subject # rubocop:disable RSpec/NamedSubject
          call_function('simplib::passgen::simpkv::set', id, password, salt, 1,
            true)
          call_function('simplib::passgen::simpkv::remove', id)

          expected = { 'keys' => {}, 'folders' => [] }
          is_expected.to run.with_params.and_return(expected)
        end

        it 'returns password info and folders when root folder is not empty' do
          subject # rubocop:disable RSpec/NamedSubject
          call_function('simplib::passgen::simpkv::set', id, password, salt, 1,
            true)
          expected = {
            'keys' => {
              id => {
                'value'    => { 'password' => password, 'salt' => salt },
                'metadata' => { 'complexity' => 1, 'complex_only' => true, 'history' => [] }
              }
            },
            'folders' => []
          }

          is_expected.to run.with_params.and_return(expected)
        end
      end

      context 'sub-folder' do
        it 'returns {} when the sub-folder does not exist' do
          is_expected.to run.with_params(sub_folder).and_return({})
        end

        it 'returns empty password and folder results when the sub-folder is empty' do
          # call subject() to make sure test Puppet environment is created
          # before we try to pre-populate the default key/value store with
          # passwords
          subject # rubocop:disable RSpec/NamedSubject
          call_function('simplib::passgen::simpkv::set', "#{sub_folder}/#{id}",
            'password', 'salt', 1, true)
          call_function('simplib::passgen::simpkv::remove', "#{sub_folder}/#{id}")

          expected = { 'keys' => {}, 'folders' => [] }
          is_expected.to run.with_params(sub_folder).and_return(expected)
        end

        it 'returns password info and folders when sub-folder is not empty' do
          subject # rubocop:disable RSpec/NamedSubject
          call_function('simplib::passgen::simpkv::set', "#{sub_folder}/#{id}", password,
            salt, 1, true)
          expected = {
            'keys' => {
              id => {
                'value'    => { 'password' => password, 'salt' => salt },
                'metadata' => { 'complexity' => 1, 'complex_only' => true, 'history' => [] }
              }
            },
            'folders' => []
          }

          is_expected.to run.with_params(sub_folder).and_return(expected)
        end
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
            }
          }
        }

        is_expected.to run.with_params('/', simpkv_options)
                          .and_raise_error(ArgumentError,
          %r{simpkv Configuration Error})
      end
    end
  end
end
