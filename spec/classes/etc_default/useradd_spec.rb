require 'spec_helper'

describe 'simplib::etc_default::useradd' do

  it { should compile.with_all_deps }
  it { should create_file('/etc/default/useradd').with_content(<<-EOM.gsub(/^\s+/,''))
       # useradd defaults file
       GROUP=100
       HOME=/home
       INACTIVE=35
       SHELL=/bin/bash
       SKEL=/etc/skel
       CREATE_MAIL_SPOOL=yes
       EOM
  }

  context 'expire' do
    let(:params){{:expire => '2020-01-10'}}
    it { should create_file('/etc/default/useradd').with_content(<<-EOM.gsub(/^\s+/,''))
       # useradd defaults file
       GROUP=100
       HOME=/home
       INACTIVE=35
       EXPIRE=#{params[:expire]}
       SHELL=/bin/bash
       SKEL=/etc/skel
       CREATE_MAIL_SPOOL=yes
       EOM
    }
  end

  bad_expires = [
    '202-01-10',
    '111',
    '2020/01/10',
    'foo'
  ]

  bad_expires.each do |exp|
    context "bad_expire: #{exp}" do
      let(:params){{:expire => exp }}
      it {
        expect {
          should compile
        }.to raise_error(/"#{exp}" does not match/)
      }
    end
  end
end
