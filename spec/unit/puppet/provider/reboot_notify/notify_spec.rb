require 'spec_helper'

describe Puppet::Type.type(:reboot_notify).provider(:notify) do
  let(:resource) {
    Puppet::Type.type(:reboot_notify).new(
      name: 'Foo',
      reason: 'Bar'
    )
  }
  let(:provider) {
    Puppet::Type.type(:reboot_notify).provider(:notify).new(resource)
  }

  before(:each) do
    @tmpdir = Dir.mktmpdir('rspec_reboot_notify')
    @target = File.join(@tmpdir, 'reboot_notifications.json')
    Puppet.stubs(:[]).with(:vardir).returns @tmpdir
  end

  after(:each) do
    FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)
  end

  context '#exists?' do
    it 'does not exist' do
      expect(provider.exists?).to be_falsey
    end

    context 'does exist' do
      it 'is empty' do
        FileUtils.touch(@target)

        expect(provider.exists?).to be_falsey
      end

      it 'is invalid' do
        File.open(@target, 'w'){|fh| fh.puts("{")}

        expect(provider.exists?).to be_falsey
      end

      it 'is json' do
        File.open(@target, 'w'){|fh| fh.puts("{}")}

        expect(provider.exists?).to be_truthy
      end
    end
  end

  context '#create' do
    it 'should create a valid, but empty JSON file' do
      expect{ provider.create }.to_not raise_error

      expect(JSON.parse(File.read(@target))).to eq({})
    end

    context 'the target directory does not exist' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.create }.to raise_error(/Could not create.*#{@target}/)
      end
    end
  end

  context '#destroy' do
    it 'should remove the target file' do
      expect{ provider.destroy }.to_not raise_error

      expect(File.exist?(@target)).to be_falsey
    end

    context 'the target has been removed' do
      it do
        FileUtils.rm_f(@target)

        expect{ provider.destroy }.to_not raise_error
      end
    end
  end

  context '#update' do
    it 'should update the file with the new content' do
      expect{ provider.update }.to_not raise_error

      output = JSON.parse(File.read(@target))

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    it 'should not erase existing content' do

      orig_data = {
        'PreExisting' => {
          'reason' => 'Condition',
          'updated' => 12345
        }
      }

      File.open(@target, 'w'){|fh| fh.puts(JSON.pretty_generate(orig_data))}

      # This populates the record content
      expect{ provider.exists?}.to_not raise_error
      expect{ provider.update }.to_not raise_error

      output = JSON.parse(File.read(@target))

      expect(output.keys).to include('PreExisting')
      expect(output['PreExisting']).to eq(orig_data['PreExisting'])

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.update}.to raise_error(/Could not update.*#{@target}/)
      end
    end
  end

  context '#self.post_resource_eval' do
    before(:each) do
      expect{ provider.exists?}.to_not raise_error
      expect{ provider.update }.to_not raise_error
    end

    let(:output) { JSON.parse(File.read(@target)) }

    it { expect{ provider.class.post_resource_eval }.to_not raise_error }

    context 'the target has invalid json' do
      it 'should fail' do
        File.open(@target, 'w'){|fh| fh.puts('{')}

        expect{ provider.class.post_resource_eval }.to raise_error(/Invalid JSON in '#{@target}'/)
      end
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.class.post_resource_eval }.to raise_error(/Could not read file '#{@target}'/)
      end
    end

    context 'with records to be expired' do
      let(:data) {{
        'ToDelete' => {
          'reason' => 'Old',
          'updated' => 12345
        },
        'ToKeep' => {
          'reason' => 'New',
          'updated' => Time.now.tv_sec
        }
      }}

      it 'should expire old records' do
        File.open(@target, 'w'){|fh| fh.puts(JSON.pretty_generate(data))}

        expect{ provider.class.post_resource_eval}.to_not raise_error

        updates = JSON.parse(File.read(@target))

        expect(updates.keys).to_not include('ToDelete')
        expect(updates.keys).to include('ToKeep')
        expect(updates['ToKeep']).to eq(data['ToKeep'])
      end
    end
  end
end
