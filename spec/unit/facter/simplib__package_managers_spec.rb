require 'spec_helper'

describe 'simplib__package_managers' do

  before :each do
    Facter.clear
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  output_map = {
    'rpm' => {
      :version => '4.11.3',
      :output => <<~RPM_OUTPUT
        RPM version 4.11.3
        RPM_OUTPUT
    },
    'yum' => {
      :version => '3.4.3',
      :output => <<~YUM_OUTPUT
        3.4.3
          Installed: rpm-4.11.3-43.el7.x86_64 at 2020-04-30 22:06
          Built    : CentOS BuildSystem <http://bugs.centos.org> at 2020-04-01 04:21
          Committed: Panu Matilainen <pmatilai@redhat.com> at 2019-10-04

          Installed: subscription-manager-1.24.26-4.el7.centos.x86_64 at 2020-11-11 15:07
          Built    : CentOS BuildSystem <http://bugs.centos.org> at 2020-08-06 17:26
          Committed: William Poteat <wpoteat@redhat.com> at 2020-07-09

          Installed: yum-3.4.3-167.el7.centos.noarch at 2020-04-30 22:06
          Built    : CentOS BuildSystem <http://bugs.centos.org> at 2020-04-02 15:56
          Committed: CentOS Sources <bugs@centos.org> at 2020-03-31

          Installed: yum-plugin-fastestmirror-1.1.31-53.el7.noarch at 2020-04-30 22:06
          Built    : CentOS BuildSystem <http://bugs.centos.org> at 2020-04-01 05:03
          Committed: Michal Domonkos <mdomonko@redhat.com> at 2019-09-10
        YUM_OUTPUT
    },
    'dnf' => {
      :version => '4.2.7',
      :output => <<~DNF_OUTPUT
        4.2.7
          Installed: dnf-0:4.2.7-7.el8_1.noarch at Sat 06 Jun 2020 07:40:12 AM GMT
          Built    : CentOS Buildsys <bugs@centos.org> at Thu 19 Dec 2019 03:44:23 PM GMT

          Installed: rpm-0:4.14.2-26.el8_1.x86_64 at Sat 06 Jun 2020 07:39:33 AM GMT
          Built    : CentOS Buildsys <bugs@centos.org> at Thu 09 Apr 2020 06:59:01 PM GMT
        DNF_OUTPUT
    },
    'apt' => {
      :version => '2.1.10',
      :output => <<~APT_OUTPUT
        apt 2.1.10
        APT_OUTPUT
    },
    'dpkg' => {
      :version => '1.20.5',
      :output => <<~DPKG_OUTPUT
        Debian 'dpkg' package management program version 1.20.5 (amd64).
        This is free software; see the GNU General Public License version 2 or
        later for copying conditions. There is NO warranty.
        DPKG_OUTPUT
    },
    'flatpak' => {
      :version => '1.6.2',
      :output => <<~FLATPAK_OUTPUT
        Flatpak 1.6.2
        FLATPAK_OUTPUT
    },
    'snap' => {
      :version => '2.47.1',
      :output => <<~SNAP_OUTPUT
        snap    2.47.1-1.el8
        snapd   2.47.1-1.el8
        series  16
        centos  8
        kernel  4.18.0-147.8.1.el8_1.x86_64
        SNAP_OUTPUT
    }
  }

  before(:each) do
    output_map.each do |pkg_mgr, opts|
      Facter::Util::Resolution.stubs(:which).with(pkg_mgr).returns("/bin/#{pkg_mgr}")
      Facter::Core::Execution.stubs(:execute).with("/bin/#{pkg_mgr} --version", :timeout => 2, :on_fail => nil).returns(opts[:output])
    end
  end

  let(:expected_output) do
    Hash[output_map.collect {|pkg_mgr, opts| [pkg_mgr, opts[:version]] }]
  end

  it do
    expect(Facter.fact('simplib__package_managers').value).to eq(expected_output)
  end

  context 'with dnf failing' do
    before(:each) do
      Facter::Util::Resolution.stubs(:which).with('dnf').returns(nil)
    end

    it do
      expected_output.delete('dnf')
      expect(Facter.fact('simplib__package_managers').value).to eq(expected_output)
    end
  end

  context 'with all failing' do
    before(:each) do
      output_map.each do |pkg_mgr, opts|
        Facter::Util::Resolution.stubs(:which).with(pkg_mgr).returns(nil)
      end
    end

    it do
      expect(Facter.fact('simplib__package_managers').value).to be_nil
    end
  end
end
