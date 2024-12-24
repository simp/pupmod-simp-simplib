#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ipaddresses' do
  shared_examples_for 'a host' do
    let(:result) { subject.execute }

    it 'returns an Array' do
      expect(result.is_a?(Array)).to be true
    end

    it 'returns an Array with no nil values' do
      expect(result.include?(nil)).not_to be true
    end

    it 'returns an Array with no empty values' do
      expect(result.include?(%r{^(\S*)$})).not_to be true
    end
  end

  # Mock out the Facts
  context 'All Interfaces Have IP Addresses' do
    let(:facts) do
      {
        interfaces: 'eth0,eth1,lo',
        ipaddress_eth0: '1.2.3.4',
        ipaddress_eth1: '5.6.7.8',
        ipaddress_lo: '127.0.0.1',
      }
    end

    it_behaves_like 'a host'
  end

  context 'All Interfaces Do Not Have IP Addresses' do
    let(:facts) do
      {
        interfaces: 'eth0,eth1,lo',
        ipaddress_eth0: '1.2.3.4',
        ipaddress_lo: '127.0.0.1',
      }
    end

    it_behaves_like 'a host'
  end

  context 'The system has no interfaces' do
    let(:facts) { {} }

    it 'does not raise an error' do
      expect { subject.execute }.not_to raise_error # rubocop:disable RSpec/NamedSubject
    end
  end
end
