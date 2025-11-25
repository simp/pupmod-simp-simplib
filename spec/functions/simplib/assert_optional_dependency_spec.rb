require 'spec_helper'

describe 'simplib::assert_optional_dependency' do
  let(:func) { subject.func }

  # Stub Puppet.err to avoid output during tests
  before(:each) do
    allow(Puppet).to receive(:err)
  end

  let(:source_metadata) do
    {
      'name'    => 'my/module',
      'version' => '1.2.3',
      'simp'    => {
        'optional_dependencies' => [
          {
            'name'                => 'dep-one',
            'version_requirement' => '>= 0.0.1 < 2.0.0',
          },
          {
            'name'                => 'dep/two',
          },
          {
            'name'                => 'dep-three',
            'version_requirement' => '>= 1.2.3 < 2.0.0',
          },
        ],
      },
    }
  end

  let(:dep_one_metadata) do
    {
      'name'    => 'dep/one',
      'version' => '1.0.0',
    }
  end

  let(:dep_two_metadata) do
    {
      'name'    => 'dep-two',
      'version' => '3.4.5',
    }
  end

  let(:dep_three_metadata) do
    {
      'name'    => 'dep-three',
      'version' => '1.2.3-alpha',
    }
  end

  let(:dep_one_bad_author) do
    {
      'name'    => 'narp/one',
      'version' => '1.0.0',
    }
  end

  let(:dep_one_bad_version) do
    {
      'name'    => 'dep/one',
      'version' => '5.5.5',
    }
  end

  context 'with a source module' do
    it 'runs with no errors' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'two').and_return(dep_two_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'three').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'three').and_return(dep_three_metadata)
      is_expected.to run.with_params('my/module')
    end

    it 'fails on one missing module' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(false)
      expect(func).not_to receive(:call_function).with('load_module_metadata', 'two')

      is_expected.to run.with_params('my/module')
    end

    it 'fails on all missing modules' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(false)
      expect(func).not_to receive(:call_function).with('load_module_metadata', 'one')
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(false)
      expect(func).not_to receive(:call_function).with('load_module_metadata', 'two')

      is_expected.to run.with_params('my/module')
    end
  end

  context 'with a target module' do
    before(:each) do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).not_to receive(:call_function).with('simplib::module_exist', 'two')
      expect(func).not_to receive(:call_function).with('load_module_metadata', 'two')
    end

    context 'that exists' do
      before(:each) do
        expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      end

      context 'valid' do
        before(:each) do
          expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_metadata)
        end

        it 'long name' do
          is_expected.to run.with_params('my/module', 'dep/one')
        end

        it 'hyphen name' do
          is_expected.to run.with_params('my/module', 'dep-one')
        end

        it 'short name' do
          is_expected.to run.with_params('my/module', 'one')
        end
      end

      context 'invalid' do
        it 'author' do
          expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_bad_author)

          is_expected.to run.with_params('my/module', 'dep/one')
        end
      end
    end

    context 'that is not in the metadata' do
      it 'fails' do
        expect(func).not_to receive(:call_function).with('simplib::module_exist', 'one')

        is_expected.to run.with_params('my/module', 'badmod')
      end
    end
  end

  context 'with an out of range module' do
    it 'fails on the invalid module' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_bad_version)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'two').and_return(dep_two_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'three').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'three').and_return(dep_three_metadata)

      is_expected.to run.with_params('my/module')
    end
  end
end
