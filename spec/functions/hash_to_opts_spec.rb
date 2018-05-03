require 'spec_helper'

describe 'simplib::hash_to_opts' do

  it { is_expected.to run.with_params() \
    .and_raise_error(/expects 1 argument, got none/) }

  # basic hash
  it { is_expected.to run.with_params({'iface' => 'eth1'}).and_return('--iface=eth1') }

  # with value that has a space
  bigger_hash = {
    'iface' => 'eth1',
    'arg2'  => 'junk value'
  }
  it { is_expected.to run.with_params(bigger_hash) \
    .and_return('--iface=eth1 --arg2="junk value"') }

  # value that is a number
  it { is_expected.to run.with_params({'key' => 8}).and_return('--key=8') }

  # value that is a boolean
  it { is_expected.to run.with_params({'key' => false}).and_return('--key=false') }

  # value that is an array
  it { is_expected.to run.with_params({'key' => ['yes',true,1]}).and_return('--key="yes,true,1"') }

  # key with no value
  it { is_expected.to run.with_params({'key' => :undef}).and_return('--key') }
  it { is_expected.to run.with_params({'key' => nil}).and_return('--key') }

end
