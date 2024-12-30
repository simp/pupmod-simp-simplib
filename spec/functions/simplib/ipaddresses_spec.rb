#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ipaddresses' do
  shared_examples_for 'a host' do
    let(:result) { subject.execute }

    it 'returns an Array' do
      expect(result).to be_a(Array)
      expect(result).not_to be_empty
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
        networking: {
          interfaces: {
            eth0: { ip: '1.2.3.4' },
            eth1: { ip: '5.6.7.8' },
            lo: { ip: '127.0.0.1' },
          },
        },
      }
    end

    it_behaves_like 'a host'
  end

  context 'All Interfaces Do Not Have IP Addresses' do
    let(:facts) do
      {
        networking: {
          interfaces: {
            eth0: { ip: '1.2.3.4' },
            lo: { ip: '127.0.0.1' },
          },
        },
      }
    end

    it_behaves_like 'a host'
  end

  context 'The system has no interfaces' do
    let(:facts) { {} }

    it 'does not raise an error' do
      expect { subject.execute }.not_to raise_error # rubocop:disable RSpec/NamedSubject
    end

    it 'returns an empty Array' do
      result = subject.execute # rubocop:disable RSpec/NamedSubject
      expect(result).to be_a(Array)
      expect(result).to be_empty
    end
  end
end
