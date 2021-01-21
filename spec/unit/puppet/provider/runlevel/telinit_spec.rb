require 'spec_helper'

describe Puppet::Type.type(:runlevel).provider(:telinit) do
  let(:resource) {
    Puppet::Type.type(:runlevel).new( name: '5')
  }
  let(:provider) {
    Puppet::Type.type(:runlevel).provider(:telinit).new(resource)
  }

  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    allow_any_instance_of(Puppet::Type::Runlevel).to receive(:catalog).and_return(@catalog)

    allow(described_class).to receive(:command).with(:telinit).and_return('/sbin/telinit')
  end

  context '#level' do
    it 'should return the runlevel' do
    allow(Facter).to receive(:value).with(any_args).and_call_original
      expect(Facter).to receive(:value).with(:runlevel).and_return('5')

      expect(provider.level).to eq('5')
    end
  end

  context '#level=' do
    before(:each) do
      allow(File).to receive(:open).with(any_args).and_call_original
    end

    context 'with a normal transition' do
      it 'should succeed' do
        expect(provider).to receive(:execute).with(['/sbin/telinit', resource[:level]])

        provider.level=(resource[:level])
      end
    end

    context 'with a timeout' do
      it 'should raise an exception' do
        expect(provider).to receive(:execute).with(['/sbin/telinit', resource[:level]]).and_raise(Timeout::Error)

        expect { provider.level=(resource[:level]) }.to raise_error(/Could not transition to runlevel/)
      end
    end

    context 'persisting state' do
      before(:each) do
        require 'tempfile'

        @tempfile = Tempfile.new("#{described_class}")
      end

      after(:each) do
        FileUtils.rm(@tempfile)
      end

      context '#persist' do
        it 'returns :true if in sync' do
          @tempfile.write("id:#{resource[:level]}:initdefault:nil\n")
          @tempfile.rewind

          expect(File).to receive(:open).with('/etc/inittab', 'r').and_return(@tempfile)

          expect(provider.persist).to eq(:true)
        end

        it 'returns :false if not in sync' do
          @tempfile.write('')
          @tempfile.rewind

          expect(File).to receive(:open).with('/etc/inittab', 'r').and_return(@tempfile)

          expect(provider.persist).to eq(:false)
        end
      end

      context '#persist=' do
        it 'sets the system default runlevel' do
          @tempfile.write("id:#{resource[:level]}:initdefault:nil\n")
          @tempfile.rewind

          expect(File).to receive(:open).with('/etc/inittab', 'r').and_return(@tempfile)

          fh = IO.open(IO.sysopen(@tempfile, 'w'), 'w')

          expect(File).to receive(:open).with('/etc/inittab', 'w').and_return(fh)

          provider.persist=(resource[:level])

          expect(File.read(@tempfile)).to eq("id:#{resource[:level]}:initdefault:nil\n")
        end
      end
    end
  end
end
