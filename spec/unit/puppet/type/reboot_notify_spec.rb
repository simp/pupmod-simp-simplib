#!/usr/bin/env rspec

require 'spec_helper'

reboot_notify_type = Puppet::Type.type(:reboot_notify)

describe reboot_notify_type do
  context 'when setting parameters' do
    it 'should accept a name parameter' do
      resource = reboot_notify_type.new :name => 'foo'
      expect(resource[:name]).to eq('foo')
    end

    it 'should accept a reason parameter' do
      resource = reboot_notify_type.new :name => 'foo', :reason => 'Foo needs a reboot!'
      expect(resource[:reason]).to eq('Foo needs a reboot!')
    end
  end
end

