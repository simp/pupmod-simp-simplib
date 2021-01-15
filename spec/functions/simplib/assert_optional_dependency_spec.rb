require 'spec_helper'

describe 'simplib::assert_optional_dependency' do
  let(:func) { subject.func }

  let(:source_metadata) {
    {
      'name'    => 'my/module',
      'version' => '1.2.3',
      'simp'    => {
        'optional_dependencies' => [
          {
            'name'                => 'dep-one',
            'version_requirement' => '>= 0.0.1 < 2.0.0'
          },
          {
            'name'                => 'dep/two'
          }
        ]
      }
    }
  }

  let(:dep_one_metadata) {
    {
      'name'    => 'dep/one',
      'version' => '1.0.0'
    }
  }

  let(:dep_two_metadata) {
    {
      'name'    => 'dep-two',
      'version' => '3.4.5'
    }
  }

  let(:dep_one_bad_author) {
    {
      'name'    => 'narp/one',
      'version' => '1.0.0'
    }
  }

  let(:dep_one_bad_version) {
    {
      'name'    => 'dep/one',
      'version' => '5.5.5'
    }
  }

  context 'with a source module' do

    it 'should run with no errors' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'two').and_return(dep_two_metadata)
      is_expected.to run.with_params('my/module')
    end

    it 'should fail on one missing module' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(false)
      expect(func).to_not receive(:call_function).with('load_module_metadata', 'two')

      expect{ is_expected.to run.with_params('my/module') }.to raise_error(%r(optional dependency 'two' not found)m)
    end

    it 'should fail on all missing modules' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(false)
      expect(func).to_not receive(:call_function).with('load_module_metadata', 'one')
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(false)
      expect(func).to_not receive(:call_function).with('load_module_metadata', 'two')

      expect{ is_expected.to run.with_params('my/module') }.to raise_error(%r(optional dependency 'one' not found.+optional dependency 'two' not found)m)
    end
  end

  context 'with a target module' do
    before(:each) do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to_not receive(:call_function).with('simplib::module_exist', 'two')
      expect(func).to_not receive(:call_function).with('load_module_metadata', 'two')
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
          is_expected.to run.with_params('my/module', 'dep/one')
        end

        it 'short name' do
          is_expected.to run.with_params('my/module', 'one')
        end
      end

      context 'invalid' do
        it 'author' do
          expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_bad_author)

          expect{ is_expected.to run.with_params('my/module', 'dep/one') }.to raise_error(%r('dep/one' does not match 'narp/one'))
        end

      end
    end

    context 'that is not in the metadata' do
      it 'should fail' do
        expect(func).to_not receive(:call_function).with('simplib::module_exist', 'one')

        expect{is_expected.to run.with_params('my/module', 'three')}.to raise_error(%r('three' not found in metadata.json))
      end
    end
  end

  context 'with an out of range module' do
    it 'should fail on the invalid module' do
      expect(func).to receive(:call_function).with('load_module_metadata', 'my/module').and_return(source_metadata)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'one').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'one').and_return(dep_one_bad_version)
      expect(func).to receive(:call_function).with('simplib::module_exist', 'two').and_return(true)
      expect(func).to receive(:call_function).with('load_module_metadata', 'two').and_return(dep_two_metadata)

      expect{ is_expected.to run.with_params('my/module') }.to raise_error(%r('one-.+' does not satisfy)m)
    end
  end
end
