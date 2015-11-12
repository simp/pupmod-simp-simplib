require 'spec_helper'

describe 'simplib::sysconfig::init' do

  it { should compile.with_all_deps }
  it { should contain_file('/etc/sysconfig/init').with_content(<<-EOM.gsub(/^\s+/,'')
      BOOTUP=color
      RES_COL=60
      MOVE_TO_COL="echo -en \\\\033[${RES_COL}G"
      SETCOLOR_SUCCESS="echo -en \\\\033[0;32m"
      SETCOLOR_FAILURE="echo -en \\\\033[0;31m"
      SETCOLOR_WARNING="echo -en \\\\033[0;33m"
      SETCOLOR_NORMAL="echo -en \\\\033[0;39m"
      LOGLEVEL=3
      PROMPT=no
      AUTOSWAP=no
      EOM
    )
  }

end
