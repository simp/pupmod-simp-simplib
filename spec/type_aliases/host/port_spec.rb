require 'spec_helper'

describe 'Simplib::Host::Port' do
  # Simplib::Host::Port is Variant[Simplib::IP::Port, Simplib::Hostname::Port]

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid IP addresses and ports' do
        it { is_expected.to allow_value('1.2.3.4:80') }
        it { is_expected.to allow_value('10.0.0.255:65535') }
        it { is_expected.to allow_value('[::1]:80') }
      end

      context 'with valid host names and ports' do
        it { is_expected.to allow_value('a:80') }
        it { is_expected.to allow_value('foo:80') }
        it { is_expected.to allow_value('foo.example.com:443') }
        it { is_expected.to allow_value('foo.example.com.:443') }
      end

      context 'with malformed IPv4 addresses' do
        it { is_expected.not_to allow_value('1.2.3.400:80') }
        it { is_expected.not_to allow_value('10.0.0.256:80') }
        it { is_expected.not_to allow_value('400:80') }
      end

      context 'with other invalid values' do
        it { is_expected.not_to allow_value('') }
        it { is_expected.not_to allow_value('foo.example.com') }
        it { is_expected.not_to allow_value('foo:65536') }
        it { is_expected.not_to allow_value("foo.example.com:80\nevil") }
      end
    end
  end
end
