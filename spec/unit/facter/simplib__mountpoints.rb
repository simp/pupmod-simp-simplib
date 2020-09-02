require 'spec_helper'

describe 'simplib__mountpoints' do

  before :each do
    Facter.clear
    Facter.stubs(:value).with(:kernel).returns('Linux')
    File.stubs(:exist?).with('/proc/mounts').returns(true)

    Etc.stubs(:getgrgid).with(953).returns('read_proc')

    Facter::Util::Resolution.stubs(:exec).with('cat /proc/mounts 2> /dev/null').returns(
      <<~EOM
      rootfs / rootfs rw 0 0
      sysfs /sys sysfs rw,seclabel,nosuid,nodev,noexec,relatime 0 0
      proc /proc proc rw,nosuid,nodev,noexec,relatime,hidepid=2,gid=953 0 0
      devtmpfs /dev devtmpfs rw,seclabel,nosuid,size=2964804k,nr_inodes=741201,mode=755 0 0
      securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
      tmpfs /dev/shm tmpfs rw,seclabel,nosuid,nodev 0 0
      devpts /dev/pts devpts rw,seclabel,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
      tmpfs /run tmpfs rw,seclabel,nosuid,nodev,mode=755 0 0
      tmpfs /sys/fs/cgroup tmpfs ro,seclabel,nosuid,nodev,noexec,mode=755 0 0
      cgroup /sys/fs/cgroup/systemd cgroup rw,seclabel,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd 0 0
      pstore /sys/fs/pstore pstore rw,nosuid,nodev,noexec,relatime 0 0
      cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,seclabel,nosuid,nodev,noexec,relatime,cpuacct,cpu 0 0
      cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,seclabel,nosuid,nodev,noexec,relatime,net_prio,net_cls 0 0
      cgroup /sys/fs/cgroup/cpuset cgroup rw,seclabel,nosuid,nodev,noexec,relatime,cpuset 0 0
      cgroup /sys/fs/cgroup/memory cgroup rw,seclabel,nosuid,nodev,noexec,relatime,memory 0 0
      cgroup /sys/fs/cgroup/freezer cgroup rw,seclabel,nosuid,nodev,noexec,relatime,freezer 0 0
      cgroup /sys/fs/cgroup/devices cgroup rw,seclabel,nosuid,nodev,noexec,relatime,devices 0 0
      cgroup /sys/fs/cgroup/hugetlb cgroup rw,seclabel,nosuid,nodev,noexec,relatime,hugetlb 0 0
      cgroup /sys/fs/cgroup/perf_event cgroup rw,seclabel,nosuid,nodev,noexec,relatime,perf_event 0 0
      cgroup /sys/fs/cgroup/pids cgroup rw,seclabel,nosuid,nodev,noexec,relatime,pids 0 0
      cgroup /sys/fs/cgroup/blkio cgroup rw,seclabel,nosuid,nodev,noexec,relatime,blkio 0 0
      configfs /sys/kernel/config configfs rw,relatime 0 0
      /dev/sda1 / xfs rw,seclabel,relatime,attr2,inode64,noquota 0 0
      selinuxfs /sys/fs/selinux selinuxfs rw,relatime 0 0
      systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=32,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11393 0 0
      debugfs /sys/kernel/debug debugfs rw,relatime 0 0
      mqueue /dev/mqueue mqueue rw,seclabel,relatime 0 0
      hugetlbfs /dev/hugepages hugetlbfs rw,seclabel,relatime 0 0
      sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
      tmpfs /run/user/1000 tmpfs rw,seclabel,nosuid,nodev,relatime,size=594464k,mode=700,uid=1000,gid=1000 0 0
      tmpfs /tmp tmpfs rw,seclabel 0 0
      /dev/sda1 /var/tmp xfs rw,seclabel,relatime,attr2,inode64,noquota 0 0
      EOM
    )

    # Standard systemd tmp.mount
    Facter::Util::Resolution.stubs(:exec).with('findmnt /tmp').returns(
      <<~EOM
      TARGET SOURCE FSTYPE OPTIONS
      /tmp   tmpfs  tmpfs  rw,seclabel
      EOM
    )
    # Bind mounted onto itself
    Facter::Util::Resolution.stubs(:exec).with('findmnt /var/tmp').returns(
      <<~EOM
      TARGET   SOURCE              FSTYPE OPTIONS
      /var/tmp /dev/sda1[/var/tmp] xfs    rw,relatime,seclabel,attr2,inode64,noquota
      EOM
    )
    Facter::Util::Resolution.stubs(:exec).with('findmnt /dev/shm').returns(
      <<~EOM
      TARGET   SOURCE FSTYPE OPTIONS
      /dev/shm tmpfs  tmpfs  rw,nosuid,nodev,seclabel
      EOM
    )
    Facter::Util::Resolution.stubs(:exec).with('findmnt /proc').returns(
      <<~EOM
      TARGET SOURCE FSTYPE OPTIONS
      /proc  proc   proc   rw,nosuid,nodev,noexec,relatime,hidepid=2,gid=953
      EOM
    )
  end

  let(:min_results) {
    {
      '/tmp' => {
        'device'       => 'tmpfs',
        'filesystem'   => 'tmpfs',
        'options'      => [
          'rw',
          'seclabel'
        ],
        'options_hash' => {
          'rw'       => nil,
          'seclabel' => nil
        }
      },
      '/var/tmp' => {
        'device'       => '/var/tmp',
        'filesystem'   => 'none',
        'options'      => [
          'rw',
          'seclabel',
          'relatime',
          'attr2',
          'inode64',
          'noquota',
          'bind'
        ],
        'options_hash' => {
          'rw'       => nil,
          'seclabel' => nil,
          'relatime' => nil,
          'attr2'    => nil,
          'inode64'  => nil,
          'noquota'  => nil,
          'bind'     => nil
        }
      },
      '/dev/shm' => {
        'device'       => 'tmpfs',
        'filesystem'   => 'tmpfs',
        'options'      => [
          'rw',
          'seclabel',
          'nosuid',
          'nodev'
        ],
        'options_hash' => {
          'rw'       => nil,
          'seclabel' => nil,
          'nosuid'   => nil,
          'nodev'    => nil
        }
      },
      '/proc' => {
        'device'       => 'proc',
        'filesystem'   => 'proc',
        'options'      => [
          'rw',
          'nosuid',
          'nodev',
          'noexec',
          'relatime',
          'hidepid=2',
          'gid=953'
        ],
        'options_hash' => {
          'hidepid'  => 2,
          'gid'      => 953,
          'rw'       => nil,
          'nosuid'   => nil,
          'nodev'    => nil,
          'noexec'   => nil,
          'relatime' => nil,
          '_group'   => 'read_proc'
        }
      }
    }
  }

  context 'when Facter does not have a filled "mountpoints" fact' do
    before :each do
      Facter.stubs(:value).with('mountpoints').returns(nil)
    end

    it 'returns the minimally filled fact' do
      expect(Facter.fact('simplib__mountpoints').value).to eq(min_results)
    end
  end

  context 'when Facter returns the "mountpoints" fact' do
    # Trimmed to ditch most of the things that we don't care about
    let(:facter_mountpoints) {{
      '/' => {
        'available'       => "36.66 GiB",
        'available_bytes' => 39359275008,
        'capacity'        => "8.31%",
        'device'          => "/dev/sda1",
        'filesystem'      => "xfs",
        'options'         => [
          "rw",
          "seclabel",
          "relatime",
          "attr2",
          "inode64",
          "noquota"
        ],
        'size'            => "39.98 GiB",
        'size_bytes'      => 42927656960,
        'used'            => "3.32 GiB",
        'used_bytes'      => 3568381952
      },
      '/dev' => {
        'available'           => "2.83 GiB",
        'available_bytes'     => 3035959296,
        'capacity'            => "0%",
        'device'              => "devtmpfs",
        'filesystem'          => "devtmpfs",
        'options'             => [
          "rw",
          "seclabel",
          "nosuid",
          "size=2964804k",
          "nr_inodes=741201",
          "mode=755"
        ],
        'size'                => "2.83 GiB",
        'size_bytes'          => 3035959296,
        'used'                => "0 bytes",
        'used_bytes'          => 0
      },
      '/dev/hugepages' => {
        'available'       => "0 bytes",
        'available_bytes' => 0,
        'capacity'        => "100%",
        'device'          => "hugetlbfs",
        'filesystem'      => "hugetlbfs",
        'options'         => [
          "rw",
          "seclabel",
          "relatime"
        ],
        'size'            => "0 bytes",
        'size_bytes'      => 0,
        'used'            => "0 bytes",
        'used_bytes'      => 0
      },
      '/dev/shm' => {
        'available'       => "2.83 GiB",
        'available_bytes' => 3043655680,
        'capacity'        => "0%",
        'device'          => "tmpfs",
        'filesystem'      => "tmpfs",
        'options'         => [
          "rw",
          "seclabel",
          "nosuid",
          "nodev"
        ],
        'size'            => "2.83 GiB",
        'size_bytes'      => 3043655680,
        'used'            => "0 bytes",
        'used_bytes'      => 0
      },
      '/tmp' => {
        'available'       => "2.83 GiB",
        'available_bytes' => 3043655680,
        'capacity'        => "0%",
        'device'          => "tmpfs",
        'filesystem'      => "tmpfs",
        'options'         => [
          "rw",
          "seclabel"
        ],
        'size'            => "2.83 GiB",
        'size_bytes'      => 3043655680,
        'used'            => "0 bytes",
        'used_bytes'      => 0
      },
      '/var/tmp' => {
        'available'       => "36.66 GiB",
        'available_bytes' => 39359275008,
        'capacity'        => "8.31%",
        'device'          => "/dev/sda1",
        'filesystem'      => "xfs",
        'options'         => [
          "rw",
          "seclabel",
          "relatime",
          "attr2",
          "inode64",
          "noquota"
        ],
        'size'            => "39.98 GiB",
        'size_bytes'      => 42927656960,
        'used'            => "3.32 GiB",
        'used_bytes'      => 3568381952
      }
    }}

    before :each do
      Facter.stubs(:value).with('mountpoints').returns(facter_mountpoints)
    end

    it 'returns the merged fact' do
      require 'deep_merge'

      final_mountpoints = Marshal.load(Marshal.dump(min_results))
      final_mountpoints.deep_merge!(Marshal.load(Marshal.dump(facter_mountpoints)))

      final_mountpoints.delete_if{ |k,v| (facter_mountpoints.keys - min_results.keys).include?(k) }

      final_mountpoints['/var/tmp']['device'] = '/var/tmp'
      final_mountpoints['/var/tmp']['filesystem'] = 'none'

      expect(Facter.fact('simplib__mountpoints').value).to match(final_mountpoints)
    end
  end
end
