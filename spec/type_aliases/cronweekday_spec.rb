require 'spec_helper'

describe 'Simplib::CronWeekDay' do
  context 'with valid parameters' do
    it { is_expected.to allow_value(2)}
    it { is_expected.to allow_value([2])}
    it { is_expected.to allow_value('2')}
    it { is_expected.to allow_value(['2'])}
    it { is_expected.to allow_value('2-3')}
    it { is_expected.to allow_value(['5-6','1-2/2','*/3'])}
    it { is_expected.to allow_value('*')}
    it { is_expected.to allow_value('*/5')}
    it { is_expected.to allow_value('0-6/2')}
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value(['5-6','1-2/2','*/8'])}
    it { is_expected.not_to allow_value('0,1,2-3,5')}
    it { is_expected.not_to allow_value("'0','1','2-3','5'")}
  end
end
