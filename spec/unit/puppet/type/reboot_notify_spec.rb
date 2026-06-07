#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:reboot_notify) do
  let(:catalog) { Puppet::Resource::Catalog.new }

  before(:each) do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Puppet::Type::Reboot_notify).to receive(:catalog).and_return(catalog)
    # rubocop:enable RSpec/AnyInstance
  end

  context 'when setting parameters' do
    it 'accepts a name parameter' do
      resource = described_class.new name: 'foo', reason: 'Foo needs a reboot!'
      expect(resource[:name]).to eq('foo')
    end

    it 'accepts a reason parameter' do
      resource = described_class.new name: 'foo', reason: 'Foo needs a reboot!'
      expect(resource[:reason]).to eq('Foo needs a reboot!')
    end

    it 'accepts a log_level parameter' do
      resource = described_class.new name: 'foo', log_level: 'warning'
      expect(resource[:log_level]).to eq('warning')
    end

    it 'accepts a control_only parameter' do
      resource = described_class.new name: 'foo', control_only: true
      expect(resource[:control_only]).to eq(true)
    end

    it 'raises an error if another resource has a control_only parameter' do
      resource = described_class.new name: 'foo', control_only: true
      catalog.add_resource(resource)

      expect {
        described_class.new name: 'bar', control_only: true
      }.to raise_error(%r{You can only have one reboot_notify.*Conflicting resource found in file.* on line}m)
    end
  end
end
