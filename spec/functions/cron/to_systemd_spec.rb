require 'spec_helper'

shared_examples 'simplib::cron::to_systemd()' do |input, return_value|
  it { is_expected.to run.with_params(*input).and_return(return_value) }
end

describe 'simplib::cron::to_systemd' do
  test_hash = {
    [] => '*-* *:*',
    [0] => '*-* *:0',
    [['27', '57']] => '*-* *:27,57',
    [nil, 0] => '*-* 0:*',
    [0, 0] => '*-* 0:0',
    [0, 0, 1, nil, 0] => 'Sun 1-* 0:0',
    [nil, nil, 5] => '5-* *:*',
    [nil, nil, '*', 3] => '*-3 *:*',
    [nil, nil, 5, 3] => '5-3 *:*',
    [nil, nil, 'MAY', 3] => '5-3 *:*',
    [nil, nil, ['MAY', 'jan'], 3] => '5,1-3 *:*',
    [nil, nil, nil, nil, 'tue'] => 'tue *-* *:*',
    [nil, nil, nil, nil, 0] => 'Sun *-* *:*',
    [nil, nil, nil, nil, '0'] => 'Sun *-* *:*',
    [nil, nil, nil, nil, [0, 1]] => 'Sun,Mon *-* *:*',
    [nil, nil, nil, nil, ['1-5']] => 'Mon,Tue,Wed,Thu,Fri *-* *:*',
    ['0,3', nil, nil, nil, [0, 1]] => 'Sun,Mon *-* *:0,3',
    ['0-3', nil, nil, nil, [0, 1]] => 'Sun,Mon *-* *:0,1,2,3',
    ['0-3/2', nil, nil, nil, [0, 1]] => 'Sun,Mon *-* *:0,1,2,3/2',
    ['0/3', nil, nil, nil, [0, 1]] => 'Sun,Mon *-* *:0/3',
    [nil, '0,5', nil, nil, [0, 1]] => 'Sun,Mon *-* 0,5:*',
    [nil, '0-5', nil, nil, [0, 1]] => 'Sun,Mon *-* 0,1,2,3,4,5:*',
    [nil, '0-5/2', nil, nil, [0, 1]] => 'Sun,Mon *-* 0,1,2,3,4,5/2:*',
    [nil, '0/5', nil, nil, [0, 1]] => 'Sun,Mon *-* 0/5:*',
  }

  test_hash.each_pair do |input, output|
    it_behaves_like 'simplib::cron::to_systemd()', input.map { |x| x || '*' }, output
  end
end
