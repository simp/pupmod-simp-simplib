require 'spec_helper'

if Puppet.version.to_f >= 4.5
  test_data_type = 'Simplib::IP::V6::Port'

  singular_item = 'port'
  plural_item = 'ports'

  valid_data = [
    '[::1]:443',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:0',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:65535'
  ]

  invalid_data = [
    'localhost',
    '1.2.3.256',
    '256.0.0.1',
    '0.0.0',
    '0.0.0.0',
    '1.2.3.4',
    '127.0.0.1',
    '255.255.255.255',
    '127.0.0.1:443',
    '::1',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:65536'
  ]

  describe test_data_type, type: :class do
    describe 'valid handling' do
      let(:pre_condition) {%(
        class #{class_name} (
          #{test_data_type} $param
        ){ }

        class { '#{class_name}':
          param => #{param}
        }
      )}

      context "with valid #{plural_item}" do
        valid_data.each do |data|
          context "with #{singular_item} #{data}" do
            let(:param){ data.is_a?(String) ? "'#{data}'" : data }

            it 'should compile' do
              is_expected.to compile
            end
          end
        end
      end

      context "with invalid #{plural_item}" do
        invalid_data.each do |data|
          context "with #{singular_item} #{data}" do
            let(:param){
              data.is_a?(String) ? "'#{data}'" : data
            }

            it 'should fail to compile' do
              is_expected.to compile.and_raise_error(/parameter 'param' expects/)
            end
          end
        end
      end
    end
  end
end
