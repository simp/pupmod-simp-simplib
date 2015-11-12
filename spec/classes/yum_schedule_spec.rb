require 'spec_helper'

describe 'simplib::yum_schedule' do

  it { should compile.with_all_deps }
  it { should create_cron('yum_update') }

end
