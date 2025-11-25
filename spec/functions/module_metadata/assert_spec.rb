require 'spec_helper'

describe 'simplib::module_metadata::assert' do
  module_metadata = {
    'name' => 'simp-simplib',
    'version' => '1.2.3',
    'author' => 'Yep',
    'summary' => 'Stubby',
    'license' => 'Apache-2.0',
    'operatingsystem_support' => [
      {
        'operatingsystem' => 'Ubuntu',
        'operatingsystemrelease' => ['14.04'],
      },
    ],
  }.to_json

  valid_facts = {
    os: {
      'name' => 'Ubuntu',
      'release' => {
        'major' => '14',
        'full'  => '14.04',
      },
    },
  }

  bad_os = {
    os: {
      'name' => 'Foo',
      'release' => {
        'major' => '14',
        'full'  => '14.04',
      },
    },
  }

  bad_version = {
    os: {
      'name' => 'Ubuntu',
      'release' => {
        'major' => '10',
        'full'  => '10.04',
      },
    },
  }

  options_disable_global = {
    'enable' => false,
  }

  options_disable_blacklist = {
    'blacklist_validation' => {
      'enable' => false,
    },
  }

  options_disable_os = {
    'os_validation' => {
      'enable' => false,
    },
  }

  options_major = {
    'os_validation' => {
      'options' => {
        'release_match' => 'major',
      },
    },
  }

  options_full = {
    'os_validation' => {
      'options' => {
        'release_match' => 'full',
      },
    },
  }

  blacklist_no_match = {
    'blacklist' => [ 'Foo', { 'Bar' => '1.1.1' } ],
  }

  blacklist_base = {
    'blacklist' => [ 'Ubuntu' ],
  }

  blacklist_advanced = {
    'blacklist' => [ { 'Ubuntu' => '14.04' } ],
  }

  blacklist_major = {
    'blacklist_validation' => {
      'options' => {
        'release_match' => 'major',
      },
    },
  }

  blacklist_full = {
    'blacklist_validation' => {
      'options' => {
        'release_match' => 'full',
      },
    },
  }

  options_fatal = {
    'fatal' => true,
  }

  let(:pre_condition) do
    <<~PRE_CONDITION
      function load_module_metadata(String $any) {
        parsejson('#{module_metadata}')
      }
    PRE_CONDITION
  end

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

      context 'when disabled globally' do
        it { is_expected.to run.with_params('simplib', options_disable_global) }
      end
    end

    context 'without a match' do
      context 'at the OS' do
        let(:facts) { bad_os }

        it 'emits a non-fatal error by default' do
          is_expected.to run.with_params('simplib')
        end

        it 'raises a fatal error when fatal is true' do
          expect { is_expected.to run.with_params('simplib', options_fatal) }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'})
        end

        context 'when disabled globally' do
          it { is_expected.to run.with_params('simplib', options_disable_global) }
        end

        context 'when disabled locally' do
          it { is_expected.to run.with_params('simplib', options_disable_os) }
        end
      end

      context 'at the major version' do
        let(:facts) { bad_version }

        it 'emits a non-fatal error by default' do
          is_expected.to run.with_params('simplib', options_major)
        end

        it 'raises a fatal error when fatal is true' do
          expect {
            is_expected.to run.with_params('simplib', options_major.merge(options_fatal))
          }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'})
        end

        context 'when disabled globally' do
          it { is_expected.to run.with_params('simplib', options_major.merge(options_disable_global)) }
        end

        context 'when disabled locally' do
          it { is_expected.to run.with_params('simplib', options_major.merge(options_disable_os)) }
        end
      end

      context 'at the full version' do
        let(:facts) { bad_version }

        it 'emits a non-fatal error by default' do
          is_expected.to run.with_params('simplib', options_full)
        end

        it 'raises a fatal error when fatal is true' do
          expect {
            is_expected.to run.with_params('simplib', options_full.merge(options_fatal))
          }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported by 'simplib'})
        end

        context 'when disabled globally' do
          it { is_expected.to run.with_params('simplib', options_full.merge(options_disable_global)) }
        end

        context 'when disabled locally' do
          it { is_expected.to run.with_params('simplib', options_full.merge(options_disable_os)) }
        end
      end
    end
  end

  context 'with a blacklist' do
    context 'with no match' do
      let(:facts) { valid_facts }

      it { is_expected.to run.with_params('simplib', blacklist_no_match) }
    end

    context 'with an OS match' do
      let(:facts) { valid_facts }

      context 'with a simple list' do
        it 'emits a non-fatal error by default' do
          is_expected.to run.with_params('simplib', blacklist_base)
        end

        it 'raises a fatal error when fatal is true' do
          expect {
            is_expected.to run.with_params('simplib', blacklist_base.merge(options_fatal))
          }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
        end

        context 'when disabled globally' do
          it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_global)) }
        end

        context 'when disabled locally' do
          it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_blacklist)) }
        end

        context 'at the major version' do
          it 'emits a non-fatal error by default' do
            is_expected.to run.with_params('simplib', blacklist_base.merge(blacklist_major))
          end

          it 'raises a fatal error when fatal is true' do
            expect {
              is_expected.to run.with_params('simplib', blacklist_base.merge(blacklist_major).merge(options_fatal))
            }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
          end

          context 'when disabled globally' do
            it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_global)) }
          end

          context 'when disabled locally' do
            it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_blacklist)) }
          end
        end

        context 'at the full version' do
          it 'emits a non-fatal error by default' do
            is_expected.to run.with_params('simplib', blacklist_base.merge(blacklist_full))
          end

          it 'raises a fatal error when fatal is true' do
            expect {
              is_expected.to run.with_params('simplib', blacklist_base.merge(blacklist_full).merge(options_fatal))
            }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
          end

          context 'when disabled globally' do
            it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_global)) }
          end

          context 'when disabled locally' do
            it { is_expected.to run.with_params('simplib', blacklist_base.merge(options_disable_blacklist)) }
          end
        end
      end

      context 'with complex options' do
        it 'emits a non-fatal error by default' do
          is_expected.to run.with_params('simplib', blacklist_advanced)
        end

        it 'raises a fatal error when fatal is true' do
          expect {
            is_expected.to run.with_params('simplib', blacklist_advanced.merge(options_fatal))
          }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
        end

        context 'when disabled globally' do
          it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(options_disable_global)) }
        end

        context 'when disabled locally' do
          it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(options_disable_blacklist)) }
        end

        context 'at the major version' do
          it 'emits a non-fatal error by default' do
            is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_major))
          end

          it 'raises a fatal error when fatal is true' do
            expect {
              is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_major).merge(options_fatal))
            }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
          end

          context 'when disabled globally' do
            it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_major.merge(options_disable_global))) }
          end

          context 'when disabled locally' do
            it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_major.merge(options_disable_blacklist))) }
          end
        end

        context 'at the full version' do
          it 'emits a non-fatal error by default' do
            is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_full))
          end

          it 'raises a fatal error when fatal is true' do
            expect {
              is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_full).merge(options_fatal))
            }.to raise_error(%r{OS '#{facts[:os]['name']} #{facts[:os]['release']['full']}' is not supported at '})
          end

          context 'when disabled globally' do
            it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_full.merge(options_disable_global))) }
          end

          context 'when disabled locally' do
            it { is_expected.to run.with_params('simplib', blacklist_advanced.merge(blacklist_full.merge(options_disable_blacklist))) }
          end
        end
      end
    end
  end
end
