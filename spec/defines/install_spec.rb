require 'spec_helper'

describe 'simplib::install', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let(:title) { 'Test' }

      context 'with defaults' do
        let(:params) do
          {
            packages: {
              'foo' => :undef,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_package('foo').with_ensure('installed') }
      end

      context 'with an empty hash for options' do
        let(:params) do
          {
            packages: {
              'foo' => {},
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_package('foo').with_ensure('installed') }
      end

      unless os_facts[:kernel].casecmp('windows')
        context 'with alternate defaults' do
          let(:params) do
            {
              packages: {
                'foo' => :undef,
              },
              defaults: {
                'ensure' => 'latest',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_package('foo').with_ensure('latest') }
        end

        context 'with package specific overrides' do
          let(:params) do
            {
              packages: {
                'foo' => :undef,
                'bar' => {
                  'ensure' => 'installed',
                },
              },
              defaults: {
                'ensure' => 'latest',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_package('foo').with_ensure('latest') }
          it { is_expected.to create_package('bar').with_ensure('installed') }
        end
      end
    end
  end
end
