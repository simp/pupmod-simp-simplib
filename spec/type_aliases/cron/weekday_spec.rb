require 'spec_helper'

describe 'Simplib::Cron::WeekDay' do
  context 'with valid parameters' do
    it { is_expected.to allow_value('0')}
    it { is_expected.to allow_value('2')}
    it { is_expected.to allow_value('7')}  #Sunday can be 0 or 7
    it { is_expected.to allow_value('sun')}
    it { is_expected.to allow_value('sun,mon,wed,tue')}
    it { is_expected.to allow_value('SUN')}
    it { is_expected.to allow_value('SUN,MON,WED,TUE')}
    it { is_expected.to allow_value('SUN,mon,wed,TUE')}
    it { is_expected.to allow_value('*')}
    it { is_expected.to allow_value('*/5')}
    it { is_expected.to allow_value('L')}
    it { is_expected.to allow_value('5L')}
    it { is_expected.to allow_value('?')}
    it { is_expected.to allow_value('2#3')}
    it { is_expected.to allow_value('TUE#3')}
    it { is_expected.to allow_value('/3')}
    it { is_expected.to allow_value('2/5')}
    it { is_expected.to allow_value('1,4-5,3L,2/6')}
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value('BIRTHDAY')}
    it { is_expected.not_to allow_value('2#WED')}
    it { is_expected.not_to allow_value('SUNDAY')}
    it { is_expected.not_to allow_value('1,MON,3,5')}
    it { is_expected.not_to allow_value('TUE-5')}
    it { is_expected.not_to allow_value('TUE/3')}
    it { is_expected.not_to allow_value('-2')}
    it { is_expected.not_to allow_value('9')}
    it { is_expected.not_to allow_value('#')}
    it { is_expected.not_to allow_value('#3')}
    it { is_expected.not_to allow_value('%')}
    it { is_expected.not_to allow_value('3/*')}
    it { is_expected.not_to allow_value('3-/5')}
    it { is_expected.not_to allow_value('3#6')} #not allowing past 5, because that is max occurances of a day in a month
  end
end
