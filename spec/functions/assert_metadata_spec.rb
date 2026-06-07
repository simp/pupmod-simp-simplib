require 'spec_helper'

describe 'simplib::assert_metadata' do
  let(:module_metadata) do
    {
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
  end

  let(:valid_facts) do
    {
      os: {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '14',
          'full'  => '14.04',
        },
      },
    }
  end

  let(:bad_os) do
    {
      os: {
        'name' => 'Foo',
        'release' => {
          'major' => '14',
          'full'  => '14.04',
        },
      },
    }
  end

  let(:bad_version) do
    {
      os: {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '10',
          'full'  => '10.04',
        },
      },
    }
  end

  let(:options_major) do
    {
      'os' => {
        'options' => {
          'release_match' => 'major',
        },
      },
    }
  end

  let(:options_full) do
    {
      'os' => {
        'options' => {
          'release_match' => 'full',
        },
      },
    }
  end

  let(:options_disable_global) { { 'enable' => false } }

  let(:options_disable_validation) do
    {
      'os' => {
        'validate' => false,
      },
    }
  end

  let(:options_fatal) { { 'fatal' => true } }

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
    end

    context 'when disabled' do
      let(:facts) { bad_os }

      context 'globally' do
        it { is_expected.to run.with_params('simplib', options_disable_global) }
      end

      context 'os validation' do
        it { is_expected.to run.with_params('simplib', options_disable_validation) }
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
      end
    end
  end
end
