# frozen_string_literal: true

require 'spec_helper'

describe 'simplib__numa' do
  before :each do
    Facter.clear
    Facter.stubs(:value).with(:kernel).returns('Linux')
    File.expects(:exist?).with('/sys/devices/system/node').once.returns(true)
  end

  context 'with files set for two NUMA zones ' do
    before :each do
      File.expects(:exist?).with('/sys/devices/system/node/possible').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/possible').once.returns("0-1")

      File.expects(:exist?).with('/sys/devices/system/node/online').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/online').once.returns("0-1")

      @memory1_tempdir = Dir.mktmpdir
      @memory2_tempdir = Dir.mktmpdir

      node0 = File.join(@memory1_tempdir, 'node0')
      node1 = File.join(@memory2_tempdir, 'node1')

      Dir.mkdir(node0)
      Dir.mkdir(node1)

      Dir.stubs(:glob).with('/sys/devices/system/node/node*').returns([node0, node1])
    end

    after :each do
      FileUtils.remove_entry(@memory1_tempdir) if File.directory?(@memory1_tempdir)
      FileUtils.remove_entry(@memory2_tempdir) if File.directory?(@memory2_tempdir)
    end

    context 'with two NUMA zones' do
      before :each do
        File.open(File.join(@memory1_tempdir, 'node0', 'meminfo'), 'w') do |fh|
          fh.puts <<~EOMEM
            Node 0 MemTotal:       16094344 kB
            Node 0 MemFree:         1459276 kB
            Node 0 MemUsed:        14635068 kB
            Node 0 Active:          7113068 kB
            Node 0 Inactive:        5666656 kB
            Node 0 Active(anon):    3718696 kB
            Node 0 Inactive(anon):   911684 kB
            Node 0 Active(file):    3394372 kB
            Node 0 Inactive(file):  4754972 kB
            Node 0 Unevictable:      278436 kB
            Node 0 Mlocked:            2044 kB
            Node 0 Dirty:               716 kB
            Node 0 Writeback:             0 kB
            Node 0 FilePages:       9088236 kB
            Node 0 Mapped:          1068884 kB
            Node 0 AnonPages:       3970156 kB
            Node 0 Shmem:            940720 kB
            Node 0 KernelStack:       17552 kB
            Node 0 PageTables:        40160 kB
            Node 0 NFS_Unstable:          0 kB
            Node 0 Bounce:                0 kB
            Node 0 WritebackTmp:          0 kB
            Node 0 KReclaimable:     519780 kB
            Node 0 Slab:             926580 kB
            Node 0 SReclaimable:     519780 kB
            Node 0 SUnreclaim:       406800 kB
            Node 0 AnonHugePages:         0 kB
            Node 0 ShmemHugePages:        0 kB
            Node 0 ShmemPmdMapped:        0 kB
            Node 0 FileHugePages:        0 kB
            Node 0 FilePmdMapped:        0 kB
            Node 0 HugePages_Total:     0
            Node 0 HugePages_Free:      0
            Node 0 HugePages_Surp:      0
            EOMEM
        end

        File.open(File.join(@memory2_tempdir, 'node1', 'meminfo'), 'w') do |fh|
          fh.puts <<~EOMEM
            Node 1 MemTotal:       16094344 kB
            Node 1 MemFree:         1459276 kB
            Node 1 MemUsed:        14635068 kB
            Node 1 Active:          7113068 kB
            Node 1 Inactive:        5666656 kB
            Node 1 Active(anon):    3718696 kB
            Node 1 Inactive(anon):   911684 kB
            Node 1 Active(file):    3394372 kB
            Node 1 Inactive(file):  4754972 kB
            Node 1 Unevictable:      278436 kB
            Node 1 Mlocked:            2044 kB
            Node 1 Dirty:               716 kB
            Node 1 Writeback:             0 kB
            Node 1 FilePages:       9088236 kB
            Node 1 Mapped:          1068884 kB
            Node 1 AnonPages:       3970156 kB
            Node 1 Shmem:            940720 kB
            Node 1 KernelStack:       17552 kB
            Node 1 PageTables:        40160 kB
            Node 1 NFS_Unstable:          0 kB
            Node 1 Bounce:                0 kB
            Node 1 WritebackTmp:          0 kB
            Node 1 KReclaimable:     519780 kB
            Node 1 Slab:             926580 kB
            Node 1 SReclaimable:     519780 kB
            Node 1 SUnreclaim:       406800 kB
            Node 1 AnonHugePages:         0 kB
            Node 1 ShmemHugePages:        0 kB
            Node 1 ShmemPmdMapped:        0 kB
            Node 1 FileHugePages:        0 kB
            Node 1 FilePmdMapped:        0 kB
            Node 1 HugePages_Total:     0
            Node 1 HugePages_Free:      0
            Node 1 HugePages_Surp:      0
            EOMEM
        end
      end

      it do
        expect(Facter.fact('simplib__numa').value).to eq({
          'possible' => '0-1',
          'online'   => '0-1',
          'nodes'    => ['node0', 'node1'],
          'node0'    => { 'MemTotalBytes' => 16480608256 },
          'node1'    => { 'MemTotalBytes' => 16480608256 }
        })
      end
    end
  end

  context 'with files set for one NUMA zone online ' do
    before :each do
      File.expects(:exist?).with('/sys/devices/system/node/possible').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/possible').once.returns("0-1")

      File.expects(:exist?).with('/sys/devices/system/node/online').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/online').once.returns("0")

      @memory1_tempdir = Dir.mktmpdir
      @memory2_tempdir = Dir.mktmpdir

      node0 = File.join(@memory1_tempdir, 'node0')
      node1 = File.join(@memory2_tempdir, 'node1')

      Dir.mkdir(node0)
      Dir.mkdir(node1)

      Dir.stubs(:glob).with('/sys/devices/system/node/node*').returns([node0, node1])
    end

    after :each do
      FileUtils.remove_entry(@memory1_tempdir) if File.directory?(@memory1_tempdir)
      FileUtils.remove_entry(@memory2_tempdir) if File.directory?(@memory2_tempdir)
    end

    context 'with two NUMA zones' do
      before :each do
        File.open(File.join(@memory1_tempdir, 'node0', 'meminfo'), 'w') do |fh|
          fh.puts <<~EOMEM
            Node 0 MemTotal:       16094344 kB
            Node 0 MemFree:         1459276 kB
            Node 0 MemUsed:        14635068 kB
            Node 0 Active:          7113068 kB
            Node 0 Inactive:        5666656 kB
            Node 0 Active(anon):    3718696 kB
            Node 0 Inactive(anon):   911684 kB
            Node 0 Active(file):    3394372 kB
            Node 0 Inactive(file):  4754972 kB
            Node 0 Unevictable:      278436 kB
            Node 0 Mlocked:            2044 kB
            Node 0 Dirty:               716 kB
            Node 0 Writeback:             0 kB
            Node 0 FilePages:       9088236 kB
            Node 0 Mapped:          1068884 kB
            Node 0 AnonPages:       3970156 kB
            Node 0 Shmem:            940720 kB
            Node 0 KernelStack:       17552 kB
            Node 0 PageTables:        40160 kB
            Node 0 NFS_Unstable:          0 kB
            Node 0 Bounce:                0 kB
            Node 0 WritebackTmp:          0 kB
            Node 0 KReclaimable:     519780 kB
            Node 0 Slab:             926580 kB
            Node 0 SReclaimable:     519780 kB
            Node 0 SUnreclaim:       406800 kB
            Node 0 AnonHugePages:         0 kB
            Node 0 ShmemHugePages:        0 kB
            Node 0 ShmemPmdMapped:        0 kB
            Node 0 FileHugePages:        0 kB
            Node 0 FilePmdMapped:        0 kB
            Node 0 HugePages_Total:     0
            Node 0 HugePages_Free:      0
            Node 0 HugePages_Surp:      0
            EOMEM
        end

        File.open(File.join(@memory2_tempdir, 'node1', 'meminfo'), 'w') do |fh|
          fh.puts <<~EOMEM
            Node 1 MemTotal:       16094344 kB
            Node 1 MemFree:         1459276 kB
            Node 1 MemUsed:        14635068 kB
            Node 1 Active:          7113068 kB
            Node 1 Inactive:        5666656 kB
            Node 1 Active(anon):    3718696 kB
            Node 1 Inactive(anon):   911684 kB
            Node 1 Active(file):    3394372 kB
            Node 1 Inactive(file):  4754972 kB
            Node 1 Unevictable:      278436 kB
            Node 1 Mlocked:            2044 kB
            Node 1 Dirty:               716 kB
            Node 1 Writeback:             0 kB
            Node 1 FilePages:       9088236 kB
            Node 1 Mapped:          1068884 kB
            Node 1 AnonPages:       3970156 kB
            Node 1 Shmem:            940720 kB
            Node 1 KernelStack:       17552 kB
            Node 1 PageTables:        40160 kB
            Node 1 NFS_Unstable:          0 kB
            Node 1 Bounce:                0 kB
            Node 1 WritebackTmp:          0 kB
            Node 1 KReclaimable:     519780 kB
            Node 1 Slab:             926580 kB
            Node 1 SReclaimable:     519780 kB
            Node 1 SUnreclaim:       406800 kB
            Node 1 AnonHugePages:         0 kB
            Node 1 ShmemHugePages:        0 kB
            Node 1 ShmemPmdMapped:        0 kB
            Node 1 FileHugePages:        0 kB
            Node 1 FilePmdMapped:        0 kB
            Node 1 HugePages_Total:     0
            Node 1 HugePages_Free:      0
            Node 1 HugePages_Surp:      0
            EOMEM
        end
      end

      it do
        expect(Facter.fact('simplib__numa').value).to eq({
          'possible' => '0-1',
          'online'   => '0',
          'nodes'    => ['node0', 'node1'],
          'node0'    => { 'MemTotalBytes' => 16480608256 },
          'node1'    => { 'MemTotalBytes' => 16480608256 }
        })
      end
    end
  end

  context 'with files set for one NUMA zone ' do
    before :each do
      File.expects(:exist?).with('/sys/devices/system/node/possible').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/possible').once.returns("0")

      File.expects(:exist?).with('/sys/devices/system/node/online').once.returns(true)
      File.expects(:read).with('/sys/devices/system/node/online').once.returns("0")

      @memory1_tempdir = Dir.mktmpdir

      node0 = File.join(@memory1_tempdir, 'node0')

      Dir.mkdir(node0)

      Dir.stubs(:glob).with('/sys/devices/system/node/node*').returns([node0])
    end

    after :each do
      FileUtils.remove_entry(@memory1_tempdir) if File.directory?(@memory1_tempdir)
    end

    context 'with two NUMA zones' do
      before :each do
        File.open(File.join(@memory1_tempdir, 'node0', 'meminfo'), 'w') do |fh|
          fh.puts <<~EOMEM
            Node 0 MemTotal:       16094344 kB
            Node 0 MemFree:         1459276 kB
            Node 0 MemUsed:        14635068 kB
            Node 0 Active:          7113068 kB
            Node 0 Inactive:        5666656 kB
            Node 0 Active(anon):    3718696 kB
            Node 0 Inactive(anon):   911684 kB
            Node 0 Active(file):    3394372 kB
            Node 0 Inactive(file):  4754972 kB
            Node 0 Unevictable:      278436 kB
            Node 0 Mlocked:            2044 kB
            Node 0 Dirty:               716 kB
            Node 0 Writeback:             0 kB
            Node 0 FilePages:       9088236 kB
            Node 0 Mapped:          1068884 kB
            Node 0 AnonPages:       3970156 kB
            Node 0 Shmem:            940720 kB
            Node 0 KernelStack:       17552 kB
            Node 0 PageTables:        40160 kB
            Node 0 NFS_Unstable:          0 kB
            Node 0 Bounce:                0 kB
            Node 0 WritebackTmp:          0 kB
            Node 0 KReclaimable:     519780 kB
            Node 0 Slab:             926580 kB
            Node 0 SReclaimable:     519780 kB
            Node 0 SUnreclaim:       406800 kB
            Node 0 AnonHugePages:         0 kB
            Node 0 ShmemHugePages:        0 kB
            Node 0 ShmemPmdMapped:        0 kB
            Node 0 FileHugePages:        0 kB
            Node 0 FilePmdMapped:        0 kB
            Node 0 HugePages_Total:     0
            Node 0 HugePages_Free:      0
            Node 0 HugePages_Surp:      0
            EOMEM
        end
      end

      it do
        expect(Facter.fact('simplib__numa').value).to eq({
          'possible' => '0',
          'online'   => '0',
          'nodes'    => ['node0'],
          'node0'    => { 'MemTotalBytes' => 16480608256 }
        })
      end
    end
  end
end
