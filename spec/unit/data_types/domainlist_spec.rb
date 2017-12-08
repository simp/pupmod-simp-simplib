require 'spec_helper'

test_data_type = 'Simplib::Domainlist'
plural_item    = 'Arrays of DNS domain names'
singular_item  = 'Array of DNS domain names'

valid_data = [
  ['test.com','test','t','0.t-t.0.t','0-0.0-0'],
  ['0-0'],
]

invalid_data = [
  ['test.com','test','t','test-.com'],
  ['-test'],
  ['t.t.t.t.0', 'test.com'],
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
        context "with #{singular_item} '#{data}'" do
          let(:param){ data.is_a?(String) ? "'#{data}'" : data }

          it 'should compile' do
            is_expected.to compile
          end
        end
      end
    end

    context "with invalid #{plural_item}" do
      invalid_data.each do |data|
        context "with #{singular_item} '#{data}'" do
          let(:param){
            data.is_a?(String) ? "'#{data}'" : data
          }

          it 'should fail to compile' do
            is_expected.to compile.and_raise_error(/parameter 'param'( index \d+)? expects/)
          end
        end
      end
    end
  end
end
