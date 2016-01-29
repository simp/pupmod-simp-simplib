require 'spec_helper'

describe 'simplib::profile_settings' do
  let(:facts){{
    :operatingsystem => 'CentOS',
    :operatingsystemrelease => '6.5',
    :operatingsystemmajrelease => '6'
  }}

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to create_file('/etc/profile.d/simp.sh').with_content(/TMOUT=900/) }
  it { is_expected.to create_file('/etc/profile.d/simp.sh').with_content(/mesg n/) }
  it { is_expected.to create_file('/etc/profile.d/simp.csh').with_content(/autologout=15/) }
  it { is_expected.to create_file('/etc/profile.d/simp.csh').with_content(/mesg n/) }

  context 'user_whitelist' do
    let(:params){{ :user_whitelist => ['bob', 'alice', 'eve'] }}

    it { is_expected.to create_file('/etc/profile.d/simp.sh').with_content(
      /for user in bob alice eve; do/
    )}
    it { is_expected.to create_file('/etc/profile.d/simp.csh').with_content(
      /foreach user \(bob alice eve\)/
    )}
  end

  context 'prepend' do
    let(:params){{
      :prepend => {
        'sh' => 'foo bar baz',
        'csh' => 'baz bar foo',
        'foo' => 'what?'
      }
    }}

    it { is_expected.to create_file('/etc/profile.d/simp.sh').with_content(
      /#{params[:prepend][:sh]}.*TMOUT/
    )}
    it { is_expected.to create_file('/etc/profile.d/simp.csh').with_content(
      /#{params[:prepend][:csh]}.*autologout/
    )}
    it { is_expected.not_to create_file('/etc/profile.d/simp.sh').with_content(/#{params[:prepend]['foo']}/) }
    it { is_expected.not_to create_file('/etc/profile.d/simp.csh').with_content(/#{params[:prepend]['foo']}/) }
  end

  context 'append' do
    let(:params){{
      :append => {
        'sh' => 'foo bar baz',
        'csh' => 'baz bar foo',
        'foo' => 'what?'
      }
    }}

    it { is_expected.to create_file('/etc/profile.d/simp.sh').with_content(
      /TMOUT.*#{params[:append][:sh]}/
    )}
    it { is_expected.to create_file('/etc/profile.d/simp.csh').with_content(
      /autologout.*#{params[:append][:csh]}/
    )}
    it { is_expected.not_to create_file('/etc/profile.d/simp.sh').with_content(/#{params[:append]['foo']}/) }
    it { is_expected.not_to create_file('/etc/profile.d/simp.csh').with_content(/#{params[:append]['foo']}/) }
  end

end
