require 'spec_helper'

describe 'Simplib::Host' do
  # Simplib::Host is Variant[Simplib::IP, Simplib::Hostname], so it must accept
  # anything that is a valid IP address or a valid host name, and nothing else.

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid IP addresses' do
        it { is_expected.to allow_value('1.2.3.4') }
        it { is_expected.to allow_value('10.0.0.255') }
        it { is_expected.to allow_value('255.255.255.255') }
        it { is_expected.to allow_value('0.0.0.0') }
        it { is_expected.to allow_value('::1') }
        it { is_expected.to allow_value('2001:db8::1') }
      end

      context 'with valid host names' do
        it { is_expected.to allow_value('a') }
        it { is_expected.to allow_value('foo') }
        it { is_expected.to allow_value('foo.example.com') }
        it { is_expected.to allow_value('foo.example.com.') }
        it { is_expected.to allow_value('3com') }
      end

      context 'with malformed IPv4 addresses' do
        # These are neither valid IP addresses nor valid host names. They were
        # accepted before the Simplib::Hostname fix, which meant Simplib::Host
        # silently accepted fat-fingered octets.
        it { is_expected.not_to allow_value('1.2.3.400') }
        it { is_expected.not_to allow_value('10.0.0.256') }
        it { is_expected.not_to allow_value('999.999.999.999') }
        it { is_expected.not_to allow_value('400') }
        it { is_expected.not_to allow_value('1.2.3.400.') }
      end

      context 'with other invalid values' do
        it { is_expected.not_to allow_value('') }
        it { is_expected.not_to allow_value('1.2.3.0/24') }
        it { is_expected.not_to allow_value('foo.example.com:80') }
        it { is_expected.not_to allow_value("foo.example.com\nevil") }
        it { is_expected.not_to allow_value("evil\nfoo.example.com") }
        it { is_expected.not_to allow_value('-foo.example.com') }
      end
    end
  end
end
