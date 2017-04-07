require 'spec_helper'

shared_examples 'simplib::inspect()' do ||
  it { is_expected.to run.with_params(input_array).and_return(return_value) }
end

describe 'simplib::inspect' do
  context 'when a parameter is passed' do
    let(:pre_condition) {%{
      $foo = 'test_value'
    }}

    it { is_expected.to run.with_params('foo') }

    it {
      is_expected.to run.with_params('foo')

      expect(catalogue.resource('Notify[DEBUG_INSPECT_foo]')).not_to be_nil
    }

    it {
      is_expected.to run.with_params('foo')

      resource = catalogue.resource('Notify[DEBUG_INSPECT_foo]')

      expect(resource[:message]).to match(/Type => String/)
    }

    it {
      is_expected.to run.with_params('foo')

      resource = catalogue.resource('Notify[DEBUG_INSPECT_foo]')

      expect(resource[:message]).to match(/Content =>.*test_value/m)
    }
  end
end
# vim: set expandtab ts=2 sw=2:
