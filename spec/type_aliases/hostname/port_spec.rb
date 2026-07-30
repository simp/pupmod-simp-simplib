require 'spec_helper'

describe 'Simplib::Hostname::Port' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid host names and ports' do
        it { is_expected.to allow_value('foo.example.com:80') }
        it { is_expected.to allow_value('my-host.test.local:443') }
        it { is_expected.to allow_value('3com:1') }
        it { is_expected.to allow_value('foo.example.com.:80') }
        it { is_expected.to allow_value('FOO.EXAMPLE.COM:80') }

        context 'single-character labels are valid' do
          it { is_expected.to allow_value('a:80') }
        end

        context 'port boundaries' do
          it { is_expected.to allow_value('foo:0') }
          it { is_expected.to allow_value('foo:65535') }
        end
      end

      context 'with invalid host names and ports' do
        context 'the highest-level label cannot be all-numeric' do
          it { is_expected.not_to allow_value('1.2.3.400:123') }
          it { is_expected.not_to allow_value('10.0.0.256:80') }
          it { is_expected.not_to allow_value('400:80') }
          it { is_expected.not_to allow_value('400.:80') }
          # Valid IPv4 addresses with ports are Simplib::IP::Port
          it { is_expected.not_to allow_value('1.2.3.4:80') }
        end

        context "labels can't begin or end with hyphens" do
          it { is_expected.not_to allow_value('-foo:80') }
          it { is_expected.not_to allow_value('foo-:80') }
        end

        context 'ports must be present and in range' do
          it { is_expected.not_to allow_value('foo.example.com') }
          it { is_expected.not_to allow_value('foo:') }
          it { is_expected.not_to allow_value('foo:65536') }
          it { is_expected.not_to allow_value('foo:99999') }
          it { is_expected.not_to allow_value('foo:http') }
        end

        context 'length limits' do
          it { is_expected.not_to allow_value("#{'a' * 64}:80") }
          it { is_expected.not_to allow_value("#{'a' * 254}:80") }
        end

        context 'the pattern is anchored to the whole string' do
          it { is_expected.not_to allow_value("foo.com:80\nevil") }
          it { is_expected.not_to allow_value("evil\nfoo.com:80") }
        end
      end
    end
  end
end
