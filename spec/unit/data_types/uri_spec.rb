require 'spec_helper'

describe 'Simplib::URI', type: :class do
  describe 'valid handling' do
    let(:pre_condition) do
      <<~END
        class #{class_name} (
          Simplib::URI $param,
        ) { }

        class { '#{class_name}':
          param => '#{param}',
        }
      END
    end

    context 'with valid URI' do
      [
        'foo://bar',
        'f00://bar',
        'foo+bar://baz',
        'foo.bar-baz+aaa://bbb',
      ].each do |param|
        let(:param) { param }

        it "accepts #{param}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid URI' do
      [
        'foo',
        'foo@bar://baz',
        '1foo://bar',
      ].each do |param|
        let(:param) { param }

        it "rejects #{param}" do
          is_expected.to compile.and_raise_error(%r{parameter 'param' expects})
        end
      end
    end
  end
end
