require 'spec_helper'

describe 'simplib::etc_default::nss' do

  it { should compile.with_all_deps }
  it { should create_file('/etc/default/nss').with_content(<<-EOM.gsub(/^\s+/,''))
       NETID_AUTHORITATIVE=FALSE
       SERVICES_AUTHORITATIVE=FALSE
       SETENT_BATCH_READ=TRUE
       EOM
  }

end
