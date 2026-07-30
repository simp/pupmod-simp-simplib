require 'spec_helper'

describe 'Simplib::Hostname' do
  # Tests cover the host name restrictions of RFC 1123, Section 2.1

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with valid host names' do
        context 'only ASCII alpha + numbers + hyphens are allowed' do
          it { is_expected.to allow_value('test') }
          it { is_expected.to allow_value('test.com') }
          it { is_expected.to allow_value('foo.example.com') }
          it { is_expected.to allow_value('my-host.test.local') }
          it { is_expected.to allow_value('0.t-t.0.t') }
          it { is_expected.to allow_value('0-0') }
          it { is_expected.to allow_value('0-0.0-0.0-0') }
          it { is_expected.to allow_value('0f') }
          it { is_expected.to allow_value('f0') }
          it { is_expected.to allow_value('3com') }
          it { is_expected.to allow_value('test.00f') }
        end

        context 'single-character labels are valid' do
          # Regression: the previous pattern imposed an unfounded
          # two-character minimum on the highest-level label
          it { is_expected.to allow_value('a') }
          it { is_expected.to allow_value('t') }
          it { is_expected.to allow_value('a.example.com') }
        end

        context 'host names are case insensitive' do
          it { is_expected.to allow_value('FOO.EXAMPLE.COM') }
          it { is_expected.to allow_value('Foo.Example.Com') }
        end

        context 'host names may end with a period' do
          it { is_expected.to allow_value('t.') }
          it { is_expected.to allow_value('test.com.') }
        end

        context 'length limits' do
          it { is_expected.to allow_value('a' * 63) }
          it { is_expected.to allow_value("#{(['a' * 63] * 3).join('.')}.#{'a' * 61}") }
        end
      end

      context 'with invalid host names' do
        context 'the highest-level label cannot be all-numeric' do
          # A valid host name can never have the dotted-decimal form #.#.#.#,
          # since the highest-level label is always alphabetic (RFC 1123 s2.1).
          # Without this, an out-of-range IPv4 address such as a fat-fingered
          # octet validates as a host name.
          it { is_expected.not_to allow_value('1.2.3.400') }
          it { is_expected.not_to allow_value('10.0.0.256') }
          it { is_expected.not_to allow_value('999.999.999.999') }
          it { is_expected.not_to allow_value('1.2.3.4') }
          it { is_expected.not_to allow_value('400') }
          it { is_expected.not_to allow_value('0') }
          it { is_expected.not_to allow_value('0212') }
          it { is_expected.not_to allow_value('test.0') }
          it { is_expected.not_to allow_value('t.t.t.t.0') }
        end

        context 'a trailing period does not bypass the all-numeric check' do
          it { is_expected.not_to allow_value('400.') }
          it { is_expected.not_to allow_value('test.400.') }
          it { is_expected.not_to allow_value('1.2.3.400.') }
        end

        context "labels can't begin or end with hyphens" do
          it { is_expected.not_to allow_value('-test') }
          it { is_expected.not_to allow_value('test-') }
          it { is_expected.not_to allow_value('test-.test') }
          it { is_expected.not_to allow_value('test.-test') }
        end

        context 'a DNS label may be no more than 63 octets long' do
          it { is_expected.not_to allow_value('a' * 64) }
          it { is_expected.not_to allow_value('an-extremely-long-dns-label-that-is-just-over-63-characters-long.test') }
          it { is_expected.not_to allow_value('test.an-extremely-long-dns-label-that-is-just-over-63-characters-long') }
        end

        context 'a host name may be no more than 253 octets long' do
          it { is_expected.not_to allow_value("#{(['a' * 63] * 3).join('.')}.#{'a' * 62}") }
        end

        context 'the pattern is anchored to the whole string' do
          # Regression: the previous pattern used line anchors, so any
          # multi-line string containing one valid line was accepted
          it { is_expected.not_to allow_value("foo.com\nevil") }
          it { is_expected.not_to allow_value("evil\nfoo.com") }
          it { is_expected.not_to allow_value("1.2.3.400\nfoo.com") }
          it { is_expected.not_to allow_value("test.com\n") }
        end
      end

      context 'with silly things' do
        it { is_expected.not_to allow_value('') }
        it { is_expected.not_to allow_value('.') }
        it { is_expected.not_to allow_value('.host.test.local') }
        it { is_expected.not_to allow_value('host..local') }
        it { is_expected.not_to allow_value('host test.local') }
        it { is_expected.not_to allow_value('my:host.test.local') }
        it { is_expected.not_to allow_value('myhost:80') }
        it { is_expected.not_to allow_value('1.2.3.0/24') }
        it { is_expected.not_to allow_value([]) }
        it { is_expected.not_to allow_value(:undef) }
      end
    end
  end
end
