require 'spec_helper'

describe Puppet::Type.type(:runlevel).provider(:systemd) do
  let(:resource) {
    Puppet::Type.type(:runlevel).new( name: '5')
  }
  let(:provider) {
    Puppet::Type.type(:runlevel).provider(:systemd).new(resource)
  }

  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Runlevel.any_instance.stubs(:catalog).returns(@catalog)

    described_class.stubs(:command).with(:systemctl).returns('/usr/bin/systemctl')
    Facter.stubs(:value).with(:kernel).returns('Linux')
  end

  context '#level' do
    it 'should return the runlevel' do
      Facter.stubs(:value).with(:runlevel).returns('5')

      expect(provider.level).to eq('5')
    end
  end

  context '#level=' do
    context 'with a normal transition' do
      it 'should succeed' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target'])

        provider.level=(resource[:level])
      end
    end

    context 'with a timeout' do
      it 'should raise an exception' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target']).raises(Timeout::Error)

        expect { provider.level=(resource[:level]) }.to raise_error(/Could not transition to runlevel/)
      end
    end

    context '#persist' do
      it 'returns :true if in sync' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'get-default']).returns('graphical.target')

        expect(provider.persist).to eq(:true)
      end

      it 'returns :false if not in sync' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'get-default']).returns('3')

        expect(provider.persist).to eq(:false)
      end
    end

    context '#persist=' do
      it 'sets the system default runlevel' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'set-default', 'graphical.target'])

        provider.persist=(resource[:level])
      end
    end
  end
end
