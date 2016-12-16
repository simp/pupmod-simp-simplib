require 'spec_helper'

if Puppet.version.to_f >= 4.5
  describe 'Simplib::RandomPort', type: :class do
    describe 'valid handling' do
      let(:pre_condition) {%(
        class #{class_name} (
          Simplib::RandomPort $port
        ){ }

        class { '#{class_name}':
          port => #{port}
        }
      )}

      context 'with valid ports' do
        [0].each do |port|
          let(:port){ port }

          it "should work with port #{port}" do
            is_expected.to compile
          end
        end
      end

      context 'with invalid ports' do
        [1,1025,'22',true].each do |port|
          let(:port){ port }

          it "should fail on port #{port}" do
            is_expected.to compile.and_raise_error(/parameter 'port' expects/)
          end
        end
      end
    end
  end
end
