require 'spec_helper'

describe 'Simplib::Cron::Minute' do
  context 'with valid parameters' do
    it { is_expected.to allow_value('42')}
    it { is_expected.to allow_value('*')}
    it { is_expected.to allow_value('*/5')}
    it { is_expected.to allow_value('/3')}
    it { is_expected.to allow_value('2/14')}
    it { is_expected.to allow_value('0,1,12-39,44,2/7')}
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value('one')}
    it { is_expected.not_to allow_value('-2')}
    it { is_expected.not_to allow_value('60')}
    it { is_expected.not_to allow_value('')}
    it { is_expected.not_to allow_value('23/*')}
    it { is_expected.not_to allow_value('23-/25')}
  end
end
