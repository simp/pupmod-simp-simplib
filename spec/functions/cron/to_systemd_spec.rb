require 'spec_helper'

shared_examples 'simplib::cron::to_systemd()' do |input, return_value|
  it { is_expected.to run.with_params(*input).and_return(return_value) }
end

describe 'simplib::cron::to_systemd' do
  context 'with unsafe filenames' do
    test_hash = {
      [] => '*-* *:*',
      [0] => '*-* *:0',
      [nil,0] => '*-* 0:*',
      [0,0] => '*-* 0:0',
      [nil,nil,5] => '5-* *:*',
      [nil,nil,'*',3] => '*-3 *:*',
      [nil,nil,5,3] => '5-3 *:*',
      [nil,nil,'MAY',3] => '5-3 *:*',
      [nil,nil,nil,nil,'tue'] => 'tue *-* *:*',
      [nil,nil,nil,nil,0] => 'Sun *-* *:*',
    }

    test_hash.each_pair do |input, output|
      it_behaves_like 'simplib::cron::to_systemd()', input.map{|x| x ||= '*'}, output
    end
  end
end
