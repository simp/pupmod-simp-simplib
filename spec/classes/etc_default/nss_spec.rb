require 'spec_helper'

describe 'simplib::etc_default::nss' do

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to create_file('/etc/default/nss').with_content(<<-EOM.gsub(/^\s+/,''))
       NETID_AUTHORITATIVE=FALSE
       SERVICES_AUTHORITATIVE=FALSE
       SETENT_BATCH_READ=TRUE
       EOM
  }

end
