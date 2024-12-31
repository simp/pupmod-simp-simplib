#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::host_is_me' do
  context 'FQDN, hostname, and iterface facts exist' do
    let(:facts) do
      {
        networking: {
          fqdn: 'myhost.example.com',
          hostname: 'myhost',
          interfaces: {
            eth0: { ip: '1.2.3.4' },
            eth1: { ip: '5.6.7.8' },
            lo: { ip: '127.0.0.1' },
          },
        },
      }
    end

    context "one of host's hostname/IPv4 addresses matches the argument" do
      [
        'myhost.example.com',
        'myhost',
        '1.2.3.4',
        '5.6.7.8',
        'localhost',
        'localhost.localdomain',
      ].each do |matching_host|
        it { is_expected.to run.with_params(matching_host).and_return(true) }
        it { is_expected.to run.with_params(['does.not.match', matching_host, '9.10.11.12']).and_return(true) }
      end
    end

    context "none of host's hostname/IPv4 addresses matches the argument" do
      it { is_expected.to run.with_params('does.not.match').and_return(false) }
      it { is_expected.to run.with_params(['does.not.match', '9.10.11.12']).and_return(false) }
      it { is_expected.to run.with_params([]).and_return(false) }
    end

    context "argument has disallowed '127.0.0.1'" do
      it { is_expected.to run.with_params('127.0.0.1').and_return(false) }
      it { is_expected.to run.with_params(['127.0.0.1', 'does.not.match', '9.10.11.12']).and_return(false) }
    end
  end

  context 'FQDN, hostname, and iterface facts do not exist' do
    let(:facts) { {} }

    context 'a localhost variant matches the argument' do
      [
        'localhost',
        'localhost.localdomain',
      ].each do |matching_host|
        it { is_expected.to run.with_params(matching_host).and_return(true) }
        it { is_expected.to run.with_params(['does.not.match', matching_host, '9.10.11.12']).and_return(true) }
      end
    end
  end
end
