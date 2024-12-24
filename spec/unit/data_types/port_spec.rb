require 'spec_helper'

describe 'Simplib::Port', type: :class do
  describe 'valid handling' do
    let(:pre_condition) do
      <<~END
        class #{class_name} (
          Simplib::Port $port,
        ) { }

        class { '#{class_name}':
          port => #{port},
        }
      END
    end

    context 'with valid ports' do
      [0, 80, 1024, 65_535].each do |port|
        let(:port) { port }

        it "works with port #{port}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid ports' do
      [-1, 65_536, 12_345_678_910, '22', true].each do |port|
        let(:port) { port }

        it "fails on port #{port}" do
          is_expected.to compile.and_raise_error(%r{parameter 'port' expects})
        end
      end
    end
  end
end
