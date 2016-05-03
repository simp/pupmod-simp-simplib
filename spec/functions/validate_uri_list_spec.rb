require 'spec_helper'

describe 'validate_uri_list' do
  context 'IPv4' do
    it do
      expect {
        subject.call(
          [[
            'rsync://127.0.0.1:1234',
            'http://some.domain.net',
            'http://some.domain.net',
            'http://localhost.my.domain:8989',
            'fuu.bar.baz',
            'my.example.net:900'
          ]].map(&:freeze)
        )
      }.to_not raise_error

      expect {
        subject.call(
          [[
            'ldap://1.2.3.4',
            'ldaps://1.2.3.4'
          ],
          [
            'ldap',
            'ldaps'
          ]].map(&:freeze)
        )
      }.to_not raise_error
    end

    it do
      expect {
        subject.call(
          [[
            'ldap://1.2.3.4:bob:alice'
          ]].map(&:freeze)
        )
      }.to raise_error(Puppet::ParseError)
    end

    it do
      expect {
        subject.call(
          [[
            'ldap://1.2.3.4',
            'ldaps://1.2.3.4'
          ],
          [
            'http'
          ]].map(&:freeze)
        )
      }.to raise_error(Puppet::ParseError)
    end
  end

  context 'IPv6' do
    it do
      expect {
        retval = scope.function_strip_ports(
          [[
            'ldap://[2001:db8:1f70::999:de8:7648:001]:100',
            'ldaps://[2001:db8:1f70::999:de8:7648:002]'
          ]].map(&:freeze)
        )
      }.to_not raise_error

      expect {
        subject.call(
          [[
            'ldap://[2001:db8:1f70::999:de8:7648:001]:100',
            'ldaps://[2001:db8:1f70::999:de8:7648:002]'
          ],
          [
            'ldap',
            'ldaps'
          ]].map(&:freeze)
        )
      }.to_not raise_error
    end

    it do
      expect {
        subject.call(
          [[
            'ldap://[2001:db8:1f70::999:de8:7648:]'
          ]].map(&:freeze)
        )
      }.to raise_error(Puppet::ParseError)
    end

    it do
      expect {
        subject.call(
          [[
            'ldap://[2001:db8:1f70::999:de8:7648:001]:100',
            'ldaps://[2001:db8:1f70::999:de8:7648:002]'
          ],
          [
            'http'
          ]].map(&:freeze)
        )
      }.to raise_error(Puppet::ParseError)
    end
  end
end
