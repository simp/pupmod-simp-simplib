require 'spec_helper'

describe 'simplib::sudoers' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_class('sudo') }

end
