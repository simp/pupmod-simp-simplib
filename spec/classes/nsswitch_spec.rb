require 'spec_helper'

describe 'simplib::nsswitch' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        it { is_expected.to compile.with_all_deps }
        it {
          if facts[:osfamily] == 'RedHat'
            if facts[:operatingsystemrelease] < '6.7'
              is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                passwd: files
                shadow: files
                group: files
                hosts: files dns
                bootparams: nisplus [NOTFOUND=return] files
                ethers: files
                netmasks: files
                networks: files
                protocols: files
                rpc: files
                services: files
                sudoers: files
                netgroup: files
                publickey: nisplus
                automount: files nisplus
                aliases: files nisplus
                EOM
            elsif facts[:operatingsystemrelease] >= '6.7' and facts[:operatingsystemmajrelease] < '7'
              is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                passwd: files [!NOTFOUND=return] sss
                shadow: files [!NOTFOUND=return] sss
                group: files [!NOTFOUND=return] sss
                hosts: files dns
                bootparams: nisplus [NOTFOUND=return] files
                ethers: files
                netmasks: files
                networks: files
                protocols: files
                rpc: files
                services: files
                sudoers: files [!NOTFOUND=return] sss
                netgroup: files [!NOTFOUND=return] sss
                publickey: nisplus
                automount: files nisplus
                aliases: files nisplus
                EOM
            else
              is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                passwd: files [!NOTFOUND=return] sss
                shadow: files [!NOTFOUND=return] sss
                group: files [!NOTFOUND=return] sss
                hosts: files myhostname dns
                bootparams: nisplus [NOTFOUND=return] files
                ethers: files
                netmasks: files
                networks: files
                protocols: files
                rpc: files
                services: files
                sudoers: files [!NOTFOUND=return] sss
                netgroup: files [!NOTFOUND=return] sss
                publickey: nisplus
                automount: files nisplus
                aliases: files nisplus
                EOM
            end
          end
        }

        context 'with_initgroups' do
          let(:params){{ :initgroups => ['files'] }}

          it {
            if facts[:osfamily] == 'RedHat'
              if facts[:operatingsystemrelease] < '6.7'
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files
                  shadow: files
                  group: files
                  initgroups: files
                  hosts: files dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files
                  netgroup: files
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              elsif facts[:operatingsystemrelease] >= '6.7' and facts[:operatingsystemmajrelease] < '7'
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files [!NOTFOUND=return] sss
                  shadow: files [!NOTFOUND=return] sss
                  group: files [!NOTFOUND=return] sss
                  initgroups: files
                  hosts: files dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files [!NOTFOUND=return] sss
                  netgroup: files [!NOTFOUND=return] sss
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              else
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files [!NOTFOUND=return] sss
                  shadow: files [!NOTFOUND=return] sss
                  group: files [!NOTFOUND=return] sss
                  initgroups: files
                  hosts: files myhostname dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files [!NOTFOUND=return] sss
                  netgroup: files [!NOTFOUND=return] sss
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              end
            end
          }
        end

        context 'with_no_ldap' do
          let(:params){{ :use_ldap => false }}

          it {
            if facts[:osfamily] == 'RedHat'
              if facts[:operatingsystemrelease] < '6.7'
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files
                  shadow: files
                  group: files
                  hosts: files dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files
                  netgroup: files
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              elsif facts[:operatingsystemrelease] >= '6.7' and facts[:operatingsystemmajrelease] < '7'
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files [!NOTFOUND=return] sss
                  shadow: files [!NOTFOUND=return] sss
                  group: files [!NOTFOUND=return] sss
                  hosts: files dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files [!NOTFOUND=return] sss
                  netgroup: files [!NOTFOUND=return] sss
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              else
                is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
                  passwd: files [!NOTFOUND=return] sss
                  shadow: files [!NOTFOUND=return] sss
                  group: files [!NOTFOUND=return] sss
                  hosts: files myhostname dns
                  bootparams: nisplus [NOTFOUND=return] files
                  ethers: files
                  netmasks: files
                  networks: files
                  protocols: files
                  rpc: files
                  services: files
                  sudoers: files [!NOTFOUND=return] sss
                  netgroup: files [!NOTFOUND=return] sss
                  publickey: nisplus
                  automount: files nisplus
                  aliases: files nisplus
                  EOM
              end
            end
          }
        end

        context 'with_sssd' do
          let(:params){{
            :use_ldap => false,
            :use_sssd => true
          }}

          if facts[:operatingsystemmajrelease] < '7'
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] sss
              shadow: files [!NOTFOUND=return] sss
              group: files [!NOTFOUND=return] sss
              hosts: files dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files [!NOTFOUND=return] sss
              netgroup: files [!NOTFOUND=return] sss
              publickey: nisplus
              automount: files nisplus
              aliases: files nisplus
              EOM
            }
          else
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] sss
              shadow: files [!NOTFOUND=return] sss
              group: files [!NOTFOUND=return] sss
              hosts: files myhostname dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files [!NOTFOUND=return] sss
              netgroup: files [!NOTFOUND=return] sss
              publickey: nisplus
              automount: files nisplus
              aliases: files nisplus
              EOM
            }
          end
        end

        context 'with_ldap_and_not_sssd' do
          let(:params){{
            :use_ldap => true,
            :use_sssd => false
          }}

          if facts[:operatingsystemmajrelease] < '7'
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] ldap
              shadow: files [!NOTFOUND=return] ldap
              group: files [!NOTFOUND=return] ldap
              hosts: files dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files
              netgroup: files [!NOTFOUND=return] ldap
              publickey: nisplus
              automount: files [!NOTFOUND=return] nisplus ldap
              aliases: files nisplus
              EOM
            }
          else
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] ldap
              shadow: files [!NOTFOUND=return] ldap
              group: files [!NOTFOUND=return] ldap
              hosts: files myhostname dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files
              netgroup: files [!NOTFOUND=return] ldap
              publickey: nisplus
              automount: files [!NOTFOUND=return] nisplus ldap
              aliases: files nisplus
              EOM
            }
          end
        end

        context 'with_sssd_and_ldap' do
          let(:params){{
            :use_ldap => true,
            :use_sssd => true
          }}

          if facts[:operatingsystemmajrelease] < '7'
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] sss
              shadow: files [!NOTFOUND=return] sss
              group: files [!NOTFOUND=return] sss
              hosts: files dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files [!NOTFOUND=return] sss
              netgroup: files [!NOTFOUND=return] sss
              publickey: nisplus
              automount: files nisplus
              aliases: files nisplus
              EOM
            }
          else
            it { is_expected.to create_file('/etc/nsswitch.conf').with_content(<<-EOM.gsub(/^\s+/,''))
              passwd: files [!NOTFOUND=return] sss
              shadow: files [!NOTFOUND=return] sss
              group: files [!NOTFOUND=return] sss
              hosts: files myhostname dns
              bootparams: nisplus [NOTFOUND=return] files
              ethers: files
              netmasks: files
              networks: files
              protocols: files
              rpc: files
              services: files
              sudoers: files [!NOTFOUND=return] sss
              netgroup: files [!NOTFOUND=return] sss
              publickey: nisplus
              automount: files nisplus
              aliases: files nisplus
              EOM
            }
          end
        end
      end
    end
  end
end
