require 'spec_helper'

describe 'simplib::module_metadata::assert' do
  valid_facts = {
    :os => {
      'name' => 'Ubuntu',
      'release' => {
        'major' => '14',
        'full'  => '14.04'
      }
    }
  }

  bad_os = {
    :os => {
      'name' => 'Foo',
      'release' => {
        'major' => '14',
        'full'  => '14.04'
      }
    }
  }

  bad_version = {
    :os => {
      'name' => 'Ubuntu',
      'release' => {
        'major' => '10',
        'full'  => '10.04'
      }
    }
  }

  options_major = {
    'os_validation' => {
      'options' => {
        'release_match' => 'major'
      }
    }
  }

  options_full = {
    'os_validation' => {
      'options' => {
        'release_match' => 'full'
      }
    }
  }

  blacklist_no_match = {
    'blacklist' => [ 'Foo', {'Bar' => '1.1.1'} ]
  }

  blacklist_base = {
    'blacklist' => [ 'Ubuntu' ]
  }

  blacklist_advanced = {
    'blacklist' => [ {'Ubuntu' => '14.04'} ]
  }

  blacklist_major = blacklist_advanced.merge({
    'blacklist_validation' => {
      'options' => {
        'release_match' => 'major'
      }
    }
  })

  blacklist_full = blacklist_advanced.merge({
    'blacklist_validation' => {
      'options' => {
        'release_match' => 'full'
      }
    }
  })

  context 'with no version matching' do
    context 'on a supported OS' do
      let(:facts) { valid_facts }

      it { is_expected.to run.with_params('simplib') }

      context 'at the major version' do
        it { is_expected.to run.with_params('simplib', options_major) }
      end

      context 'at the full version' do
        it { is_expected.to run.with_params('simplib', options_full) }
      end
    end

    context 'without a match' do
      context 'at the OS' do
        let(:facts) { bad_os }

        it { expect { is_expected.to run.with_params('simplib') }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'/) }
      end

      context 'at the major version' do
        let(:facts) { bad_version }

        it { expect { is_expected.to run.with_params('simplib', options_major) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'/) }
      end

      context 'at the full version' do
        let(:facts) { bad_version }

        it { expect { is_expected.to run.with_params('simplib', options_full) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'/) }
      end
    end
  end

  context 'with a blacklist' do
    context 'with no match' do
      let(:facts){ valid_facts }

      it { is_expected.to run.with_params('simplib', blacklist_no_match) }
    end

    context 'with an OS match' do
      let(:facts){ valid_facts }

      context 'with a simple list' do
        it { expect { is_expected.to run.with_params('simplib', blacklist_base) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }

        context 'at the major version' do
          it { expect { is_expected.to run.with_params('simplib', blacklist_major) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }
        end

        context 'at the full version' do
          it { expect { is_expected.to run.with_params('simplib', blacklist_full) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }
        end
      end

      context 'with complex options' do
        it { expect { is_expected.to run.with_params('simplib', blacklist_advanced) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }

        context 'at the major version' do
          it { expect { is_expected.to run.with_params('simplib', blacklist_major) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }
        end

        context 'at the full version' do
          it { expect { is_expected.to run.with_params('simplib', blacklist_full) }.to raise_error(/OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '/) }
        end
      end
    end
  end
end
