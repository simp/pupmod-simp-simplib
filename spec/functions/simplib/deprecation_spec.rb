require 'spec_helper'

describe 'simplib::deprecation' do
  before :each do
    allow(ENV).to receive(:[]).with(any_args).and_call_original
  end

  context 'with SIMPLIB_NOLOG_DEPRECATIONS unset' do
    before :each do
      expect(ENV).to receive(:[]).with('SIMPLIB_NOLOG_DEPRECATIONS').and_return(nil)
    end

    it 'displays a single warning' do
      expect(Puppet).to receive(:warning).with(%r{test_func is deprecated})

      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end

    it 'displays a single warning, despite multiple calls' do
      expect(Puppet).to receive(:warning).with(%r{test_func is deprecated})

      is_expected.to run.with_params('test_key', 'test_func is deprecated')
      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end
  end

  context 'with SIMPLIB_NOLOG_DEPRECATIONS=true' do
    it 'does not display a warning' do
      expect(ENV).to receive(:[]).with('SIMPLIB_NOLOG_DEPRECATIONS').and_return('true')
      expect(Puppet).not_to receive(:warning).with(%r{test_func is deprecated})

      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end
  end
end
