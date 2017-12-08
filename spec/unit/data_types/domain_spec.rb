require 'spec_helper'

test_data_type = 'Simplib::Domain'
plural_item    = 'DNS domain names'
singular_item  = 'DNS domain name'

# RFC 3696, Section 2 compliant domain names tests
#
# RegEx + test cases developed at http://rubular.com/r/t7JwXJPv1P

# Only ASCII alpha + numbers + hyphens are allowed
valid_data = [
  'test.com',
  'test',
  't',
  '0.t-t.0.t',
  '0-0',
  '0-0.0-0.0-0',
  '0f',
  'f0',
  'test.00f',
]

invalid_data = [
  # labels can't begin or end with hyphens
  '-test',
  'test-',
  'test-.test',
  'test.-test',

  # TLDs cannot be all-numeric
  '0',
  '0212',
  'test.0',
  't.t.t.t.0',
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
            is_expected.to compile.and_raise_error(/parameter 'param' expects/)
          end
        end
      end
    end
  end
end
