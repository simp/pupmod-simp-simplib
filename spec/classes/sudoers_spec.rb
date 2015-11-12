require 'spec_helper'

describe 'simplib::sudoers' do

  it { should compile.with_all_deps }
  it { should create_class('sudo') }

end
