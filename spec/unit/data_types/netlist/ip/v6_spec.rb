require 'spec_helper'

test_data_type = 'Simplib::Netlist::IP::V6'

singular_item = 'address'
plural_item = 'addresses'

valid_data = [
  [
    '[::1]',
    '2001:db8:85a3:8d3:1319:8a2e:370:7348/128',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443',
  ],
]

invalid_data = [
  'localhost',
  [
    '0.0.0',
    '1.2.3.256',
    '::1',
    '[::1]',
    '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443',
  ],
  [
    '0.0.0.0',
    '1.2.3.4',
    '1.2.3.4/24',
    '1.2.3.4/255.255.224.0',
    '1.2.3.4:443',
  ],
]

describe test_data_type, type: :class do
  describe 'valid handling' do
    let(:pre_condition) do
      <<~END
        class #{class_name} (
          #{test_data_type} $param,
        ) { }

        class { '#{class_name}':
          param => #{param},
        }
      END
    end

    context "with valid #{plural_item}" do
      valid_data.each do |data|
        context "with #{singular_item} #{data}" do
          let(:param) { data.is_a?(String) ? "'#{data}'" : data }

          it 'compiles' do
            is_expected.to compile
          end
        end
      end
    end

    context "with invalid #{plural_item}" do
      invalid_data.each do |data|
        context "with #{singular_item} #{data}" do
          let(:param) do
            data.is_a?(String) ? "'#{data}'" : data
          end

          it 'fails to compile' do
            is_expected.to compile.and_raise_error(%r{parameter 'param'})
          end
        end
      end
    end
  end
end
