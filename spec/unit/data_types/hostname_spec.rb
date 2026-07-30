require 'spec_helper'

test_data_type = 'Simplib::Hostname'

singular_item = 'hostname'
plural_item = 'hostnames'

valid_data = [
  'all',
  'ANY',
  'localhost',
  'localhost.localdomain',
  'my-domain.com',
  'aa.bb',
  # Single-character host names are valid per RFC 1123, Section 2.1
  'a',
  'a.bb',
]

invalid_data = [
  'my_domain.com',
  '0.0.0',
  '0.0.0.0',
  '1.2.3.4',
  # The highest-level label may not be all-numeric, so a malformed
  # dotted-decimal address is not a host name (RFC 1123, Section 2.1)
  '1.2.3.400',
  '10.0.0.256',
  '400',
  '400.',
  '1.2.3.400.',
  "my-domain.com\nevil",
  '1.2.3.4/24',
  '1.2.3.4/255.255.224.0',
  '1.2.3.4:443',
  '::1',
  '[::1]',
  '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443',
]

describe test_data_type, type: :class do
  describe 'valid handling' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
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
  end
end
