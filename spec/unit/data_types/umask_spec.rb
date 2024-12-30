require 'spec_helper'

describe 'Simplib::Umask', type: :class do
  describe 'valid handling' do
    let(:pre_condition) do
      <<~END
        class #{class_name} (
          Simplib::Umask $param,
        ) { }

        class { '#{class_name}':
          param => '#{param}',
        }
      END
    end

    context 'with valid umask' do
      [
        '0000',
        '0240',
        '1111',
      ].each do |param|
        let(:param) { param }

        it "accepts #{param}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid umask' do
      [
        '12345',
        'bob',
      ].each do |param|
        let(:param) { param }

        it "rejects #{param}" do
          is_expected.to compile.and_raise_error(%r{parameter 'param' expects})
        end
      end
    end
  end
end
