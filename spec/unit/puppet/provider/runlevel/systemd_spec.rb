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
    allow_any_instance_of(Puppet::Type::Runlevel).to receive(:catalog).and_return(@catalog)

    allow(described_class).to receive(:command).with(:systemctl).and_return('/usr/bin/systemctl')
    allow(described_class).to receive(:command).with(:pgrep).and_return('/bin/pgrep')
    allow(Facter).to receive(:value).with(any_args).and_call_original
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
  end

  context '#level' do
    it 'should return the runlevel' do
      expect(Facter).to receive(:value).with(:runlevel).and_return('5')

      expect(provider.level).to eq('5')
    end
  end

  context '#level_insync?' do
    context 'with a normal transition' do
      context 'when in sync' do
        it 'should run without a warning' do
          expect(provider).to receive(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).and_return("\n")
          expect(Puppet).to receive(:warning).never

          expect(provider.level_insync?('5','5')).to be true
        end
      end

      context 'when out of sync' do
        it 'should run without a warning' do
          expect(provider).to receive(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).and_return("\n")
          expect(Puppet).to receive(:warning).never

          expect(provider.level_insync?('3','5')).to be false
        end
      end
    end

    context 'with a systemctl isolation already running' do
      it 'should emit a warning' do
        expect(provider).to receive(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).and_return("1234 systemctl isolate multi-user.target\n")
        expect(Puppet).to receive(:warning)

        expect(provider.level_insync?('5','3')).to be true
      end
    end
  end

  context '#level=' do
    context 'with a normal transition' do
      it 'should succeed' do
        expect(provider).to receive(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target'])

        provider.level=(resource[:level])
      end
    end

    context 'with a timeout' do
      it 'should raise an exception' do
        expect(provider).to receive(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target']).and_raise(Timeout::Error)

        expect { provider.level=(resource[:level]) }.to raise_error(/Could not transition to runlevel/)
      end
    end

    context '#persist' do
      it 'returns :true if in sync' do
        expect(provider).to receive(:execute).with(['/usr/bin/systemctl', 'get-default']).and_return('graphical.target')

        expect(provider.persist).to eq(:true)
      end

      it 'returns :false if not in sync' do
        expect(provider).to receive(:execute).with(['/usr/bin/systemctl', 'get-default']).and_return('3')

        expect(provider.persist).to eq(:false)
      end
    end

    context '#persist=' do
      it 'sets the system default runlevel' do
        expect(provider).to receive(:execute).with(['/usr/bin/systemctl', 'set-default', 'graphical.target'])

        provider.persist=(resource[:level])
      end
    end
  end
end
