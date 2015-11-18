require 'spec_helper'

describe 'simplib::os_bugfixes' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end


      context  "on #{os}" do
        context 'base' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('simplib::os_bugfixes') }
        end

        context 'bugfix1049656' do
          let(:params) {{ :include_bugfix1049656 => true }}

          it do
            if (facts.fetch(:osfamily) == 'RedHat') && (facts.fetch(:operatingsystemmajrelease) == 7)
              is_expected.to contain_file('/etc/init.d/bugfix1049656').with_ensure('file')
            else
              is_expected.to contain_file('/etc/init.d/bugfix1049656').with_ensure('absent')
            end
          end

          it do
            if (facts.fetch(:osfamily) == 'RedHat') && (facts.fetch(:operatingsystemmajrelease) == 7)
              is_expected.to contain_service('bugfix1049656').with_enable(true)
            else
              is_expected.to contain_service('bugfix1049656').with_enable(false)
            end
          end
        end
      end
    end
  end
end

