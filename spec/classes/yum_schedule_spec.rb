require 'spec_helper'

describe 'simplib::yum_schedule' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_cron('yum_update') }

end
