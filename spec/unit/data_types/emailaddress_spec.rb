require 'spec_helper'

describe 'Simplib::EmailAddress', type: :class do
  describe 'valid handling' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:pre_condition) do
          <<~END
            class #{class_name} (
              Simplib::EmailAddress $param,
            ) { }

            class { '#{class_name}':
              param => '#{param}',
            }
          END
        end

        context 'with valid addresses' do
          [
            'foo@bar.baz',
            'foo@bar',
            'foo@bar-baz.com',
            'foobar@bar-baz.com',
            'foo+bar@bar-baz.com',
            'foo.bar@bar-baz.com',
          ].each do |param|
            let(:param) { param }

            it "accepts #{param}" do
              is_expected.to compile
            end
          end
        end

        context 'with invalid addresses' do
          [ 'foo' ].each do |param|
            let(:param) { param }

            it "accepts #{param}" do
              is_expected.to compile.and_raise_error(%r{parameter 'param' expects})
            end
          end
        end
      end
    end
  end
end
