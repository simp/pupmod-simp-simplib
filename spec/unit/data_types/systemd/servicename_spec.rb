require 'spec_helper'

test_data_type = 'Simplib::Systemd::ServiceName'

singular_item = 'service name'
plural_item = 'service names'

valid_data = [
  'foo',
  'foo.bar',
  'foo-bar.baz',
  'foo-bar.baz:foo',
  'foo-bar.baz:foo_bar',
  'foo-bar.baz:foo_bar\baz',
  'a' * 256
]

invalid_data = [
  '',
  '@',
  'foo@',
  'a' * 257
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
            is_expected.to compile.and_raise_error(/parameter 'param'/)
          end
        end
      end
    end
  end
end
