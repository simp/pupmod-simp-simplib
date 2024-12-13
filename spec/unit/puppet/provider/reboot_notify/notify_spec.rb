require 'spec_helper'

describe Puppet::Type.type(:reboot_notify).provider(:notify) do
  let(:resource) do
    Puppet::Type.type(:reboot_notify).new(
      name: 'Foo',
      reason: 'Bar',
    )
  end
  let(:provider) { Puppet::Type.type(:reboot_notify).provider(:notify).new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:tmpdir) { Dir.mktmpdir('rspec_reboot_notify') }
  let(:target) { File.join(tmpdir, 'reboot_notifications.json') }

  before(:each) do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Puppet::Type::Reboot_notify).to receive(:catalog).and_return(catalog)
    # rubocop:enable RSpec/AnyInstance

    allow(Puppet).to receive(:[]).with(any_args).and_call_original
    expect(Puppet).to receive(:[]).with(:vardir).at_least(:once).and_return(tmpdir)
  end

  after(:each) do
    FileUtils.remove_dir(tmpdir) if File.exist?(tmpdir)
  end

  context '#exists?' do
    it 'does not exist' do
      expect(provider.exists?).to be_falsey
    end

    context 'does exist' do
      it 'is empty' do
        FileUtils.touch(target)

        expect(provider.exists?).to be_falsey
      end

      it 'is invalid' do
        File.open(target, 'w') { |fh| fh.puts('{') }

        expect(provider.exists?).to be_falsey
      end

      it 'is empty json' do
        File.open(target, 'w') { |fh| fh.puts('{}') }

        expect(provider.exists?).to be_truthy
      end

      it 'only contains metadata' do
        File.open(target, 'w') do |fh|
          fh.puts <<~EOM
            {
              "reboot_control_metadata": {
                "log_level": "notice"
              }
            }
          EOM
        end

        expect(provider.exists?).to be_truthy
      end

      context 'has a matching record' do
        it 'is in sync' do
          File.open(target, 'w') do |fh|
            fh.puts <<~EOM
              {
                "reboot_control_metadata": {
                  "log_level": "notice"
                },
                "Foo": {
                  "reason": "Bar",
                  "updated": "0000000"
                }
              }
            EOM
          end

          expect(provider.exists?).to be_truthy
        end

        it 'is out of sync' do
          File.open(target, 'w') do |fh|
            fh.puts <<~EOM
              {
                "reboot_control_metadata": {
                  "log_level": "notice"
                },
                "Foo": {
                  "reason": "Nope",
                  "updated": "0000000"
                }
              }
            EOM
          end

          expect(provider.exists?).to be_falsey
        end
      end
    end
  end

  context '#create' do
    it 'creates a valid JSON file' do
      content = nil

      expect {
        provider.create
        content = JSON.parse(File.read(target))
      }.not_to raise_error

      expect(
        content['reboot_control_metadata'],
      ).to eq({ 'log_level' => 'notice' })

      expect(content['Foo']).not_to be_nil
      expect(content['Foo']['reason']).to eq('Bar')
    end

    context 'the target directory does not exist' do
      it do
        FileUtils.remove_dir(tmpdir) if File.exist?(tmpdir)

        expect { provider.create }.to raise_error(%r{Could not create.*#{target}})
      end
    end
  end

  context '#destroy' do
    it 'removes the target file' do
      expect { provider.destroy }.not_to raise_error

      expect(File.exist?(target)).to be_falsey
    end

    context 'the target has been removed' do
      it do
        FileUtils.rm_f(target)

        expect { provider.destroy }.not_to raise_error
      end
    end
  end

  context '#update' do
    it 'updates the file with the new content' do
      expect { provider.update }.not_to raise_error

      output = JSON.parse(File.read(target))

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    it 'does not erase existing content' do
      orig_data = {
        'PreExisting' => {
          'reason' => 'Condition',
          'updated' => 12_345
        }
      }

      File.open(target, 'w') { |fh| fh.puts(JSON.pretty_generate(orig_data)) }

      # This populates the record content
      expect { provider.exists? }.not_to raise_error
      expect { provider.update }.not_to raise_error

      output = JSON.parse(File.read(target))

      expect(output.keys).to include('PreExisting')
      expect(output['PreExisting']).to eq(orig_data['PreExisting'])

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(tmpdir) if File.exist?(tmpdir)

        expect { provider.update }.to raise_error(%r{Could not update.*#{target}})
      end
    end

    context 'control_only is set' do
      let(:resource) do
        Puppet::Type.type(:reboot_notify).new(
          name: 'Foo',
          reason: 'Bar',
          control_only: true,
        )
      end

      it do
        expect { provider.update }.not_to raise_error
        expect(
          JSON.parse(File.read(target)),
        ).to eq({ 'reboot_control_metadata' => { 'log_level' => 'notice' } })
      end

      [:alert, :crit, :debug, :notice, :emerg, :err, :info, :warning].each do |log_level|
        context "log_level is #{log_level}" do
          let(:resource) do
            Puppet::Type.type(:reboot_notify).new(
              name: 'Foo',
              reason: 'Bar',
              control_only: true,
              log_level: log_level.to_s,
            )
          end

          it do
            # This should always be prevented by the Type but is here in case
            # of a regression in Puppet or a bad update to the type.
            expect(Puppet).to receive(:warning).with(%r{Invalid log_level:}).never
            expect(Puppet).to receive(log_level).with(%r{System Reboot Required Because:}).at_most(:once)

            expect { provider.update }.not_to raise_error
            expect(
              JSON.parse(File.read(target)),
            ).to eq({ 'reboot_control_metadata' => { 'log_level' => log_level.to_s } })
          end
        end
      end
    end
  end

  context '#self.post_resource_eval' do
    before(:each) do
      expect { provider.exists? }.not_to raise_error
      expect { provider.update }.not_to raise_error
    end

    let(:output) { JSON.parse(File.read(target)) }

    it do
      expect(Puppet).to receive(:notice).with(
        %r{System Reboot Required Because:},
      ).at_most(:once)

      expect { provider.class.post_resource_eval }.not_to raise_error
    end

    context 'the target has invalid json' do
      it 'fails' do
        File.open(target, 'w') { |fh| fh.puts('{') }

        expect { provider.class.post_resource_eval }.to raise_error(%r{Invalid JSON in '#{target}'})
      end
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(tmpdir) if File.exist?(tmpdir)

        expect { provider.class.post_resource_eval }.to raise_error(%r{Could not read file '#{target}'})
      end
    end

    context 'with records to be expired' do
      let(:data) do
        {
          'ToDelete' => {
            'reason' => 'Old',
            'updated' => 12_345
          },
        'ToKeep' => {
          'reason' => 'New',
          'updated' => Time.now.tv_sec
        }
        }
      end

      it 'expires old records' do
        File.open(target, 'w') { |fh| fh.puts(JSON.pretty_generate(data)) }

        expect { provider.class.post_resource_eval }.not_to raise_error

        updates = JSON.parse(File.read(target))

        expect(updates.keys).not_to include('ToDelete')
        expect(updates.keys).to include('ToKeep')
        expect(updates['ToKeep']).to eq(data['ToKeep'])
      end
    end

    context 'log_level is set' do
      let(:resource) do
        Puppet::Type.type(:reboot_notify).new(
          name: 'Foo',
          reason: 'Bar',
          log_level: 'debug',
        )
      end

      it do
        expect { provider.update }.not_to raise_error
        expect(Puppet).to receive(:debug).with(
          %r{System Reboot Required Because:},
        ).at_most(:once)
        expect { provider.class.post_resource_eval }.not_to raise_error

        content = JSON.parse(File.read(target))

        expect(content.keys).to include('Foo')
      end
    end
  end
end
