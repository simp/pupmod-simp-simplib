require 'spec_helper'

describe 'Simplib::Cron::MonthDay' do
  context 'with valid parameters' do
    it { is_expected.to allow_value('31')}
    it { is_expected.to allow_value('*')}
    it { is_expected.to allow_value('*/5')}
    it { is_expected.to allow_value('/3')}
    it { is_expected.to allow_value('2/10')}
    it { is_expected.to allow_value('1,3-5,2/7')}
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value('one')}
    it { is_expected.not_to allow_value('0')}
    it { is_expected.not_to allow_value('-2')}
    it { is_expected.not_to allow_value('44')}
    it { is_expected.not_to allow_value('')}
    it { is_expected.not_to allow_value('3/*')}
    it { is_expected.not_to allow_value('3-/5')}
  end
end
