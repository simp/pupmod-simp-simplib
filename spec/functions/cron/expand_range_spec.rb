require 'spec_helper'

shared_examples 'simplib::cron::expand_range()' do |input, return_value|
  it { is_expected.to run.with_params(*input).and_return(return_value) }
end

describe 'simplib::cron::expand_range' do
  test_hash = {
    [''] => '',
    ['1-2'] => '1,2',
    ['1-3'] => '1,2,3',
    ['3-1'] => '1,2,3',
    ['1-10'] => '1,2,3,4,5,6,7,8,9,10',
    ['Bob 1-3 Alice'] => 'Bob 1,2,3 Alice',
    ['Bob 0:4-6/2 Alice 2-3/2:3-4/1 Cheese'] => 'Bob 0:4,5,6/2 Alice 2,3/2:3,4/1 Cheese',
    [' * *:4-6/2 2-3/2:6-4/1 '] => '* *:4,5,6/2 2,3/2:4,5,6/1',
  }

  test_hash.each_pair do |input, output|
    it_behaves_like 'simplib::cron::expand_range()', input, output
  end
end
