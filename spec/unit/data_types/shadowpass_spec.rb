require 'spec_helper'

describe 'Simplib::ShadowPass', type: :class do
  describe 'valid handling' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:pre_condition) do
          <<~END
            class #{class_name} (
              Simplib::ShadowPass $foo = '$6$fdkjfdk$yj8HAo/RyW/WhYkXvTp7nQbjIZz4TMRuj/0W1bJGuQjGxea36JhUkB36BMyf8O/g0/rpRB1lPC/6KuAmgqnIn0',
            ) { }

            include #{class_name}
          END
        end

        it 'compiles' do
          is_expected.to compile
        end
      end
    end
  end
end
