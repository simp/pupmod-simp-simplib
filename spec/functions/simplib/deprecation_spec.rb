require 'spec_helper'

describe 'simplib::deprecation' do
  context 'with no SIMPLIB_LOG_DEPRECATIONS environment variable' do
    it 'should display a single warning' do
      Puppet.expects(:warning).with(includes('test_func is deprecated'))
      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end

    it 'should display a single warning, despite multiple calls' do
      Puppet.expects(:warning).with(includes('test_func is deprecated')).once
      is_expected.to run.with_params('test_key', 'test_func is deprecated')
      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end
  end

  context 'with SIMPLIB_LOG_DEPRECATIONS environment variable = "false"' do
    it 'should not display a warning' do
      ENV['SIMPLIB_LOG_DEPRECATIONS'] = 'false'
      Puppet.expects(:warning).with(includes('test_func is deprecated')).never
      is_expected.to run.with_params('test_key', 'test_func is deprecated')
    end
  end
end
