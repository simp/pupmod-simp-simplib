#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:init_ulimit) do
  context 'when setting parameters' do
    it 'accepts valid input' do
      resource = described_class.new(
        name: 'foo',
        target: 'foo_svc',
        limit_type: 'both',
        item: 'max_nice',
        value: '10',
      )
      expect(resource[:name]).to eq('foo')
      expect(resource[:item]).to eq('e')
    end

    it 'accepts composite namevars' do
      resource = described_class.new(
        name: 'v|foo_svc',
        limit_type: 'both',
        value: '10',
      )
      expect(resource[:name]).to eq('v|foo_svc')
      expect(resource[:item]).to eq('v')
      expect(resource[:target]).to eq('foo_svc')
    end

    it 'translates "unlimited" for "max_open_files"' do
      resource = described_class.new(
        name: 'foo',
        target: 'foo_svc',
        item: 'max_open_files',
        value: 'unlimited',
      )
      expect(resource[:name]).to eq('foo')
      expect(resource[:item]).to eq('n')
      expect(resource[:value]).to eq('1048576')
    end
  end
end
