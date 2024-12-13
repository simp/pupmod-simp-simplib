require 'spec_helper'

describe 'simplib::validate_port' do
  context 'valid ports' do
    it { is_expected.to run.with_params('10541') }
    it { is_expected.to run.with_params(10_541) }
    it { is_expected.to run.with_params([5555, '7777', '1', '65535']) }
    it { is_expected.to run.with_params('11', 22) }
    it { is_expected.to run.with_params('11', [5555, '7777', '1', '65535']) }
  end

  context 'invalid ports' do
    it { is_expected.to run.with_params('0').and_raise_error(%r{'0' is not a valid port}) }
    it { is_expected.to run.with_params(65_536).and_raise_error(%r{'65536' is not a valid port}) }
    it { is_expected.to run.with_params('1', '1000', '100000').and_raise_error(%r{'100000' is not a valid port}) }
    it { is_expected.to run.with_params(['1', '1000', '100000']).and_raise_error(%r{'100000' is not a valid port}) }
    it { is_expected.to run.with_params('1', ['1000', '100000']).and_raise_error(%r{'100000' is not a valid port}) }
  end
end
