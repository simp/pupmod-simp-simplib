require 'spec_helper'

describe 'get_ports' do
  # Trusted Node Data
  context 'with trusted node data' do
    it do
      hostname = 'foo.bar.baz:1234'
      hostname.freeze

      expect( subject.execute([hostname]) ).to match_array(['1234'])
    end
  end

  # IPv4
  it do
    retval = subject.execute([
      'http://some.domain.net',
      'http://some.domain.net:1234',
      'http://localhost.my.domain:8989',
      'fuu.bar.baz',
      'my.example.net:900'
    ])

    expect(retval).to match_array([
      '900',
      '1234',
      '8989'
    ])
  end

  # IPv6
  it do
    retval = subject.execute([
      'http://[2001:db8:1f70::999:de8:7648:6e8]:100',
      'http://[2001:dc8:1f70::999:de8:7648:6e8]:300',
      '[2001:dd8:1f70::bbb:de8:7648:6e8]',
      '[2001:de8:1f70::999:de8:7648:6e8]:100'
    ])

    expect(retval).to match_array([
      '100',
      '300'
    ])
  end
  # Mix
  it do
    retval = subject.execute([
      'http://[2001:db8:1f70::999:de8:7648:6e8]:100',
      'http://some.domain.net',
      'http://some.domain.net:1234',
      'http://localhost.my.domain:8989',
      'fuu.bar.baz',
      'my.example.net:900',
      'http://[2001:dc8:1f70::999:de8:7648:6e8]:300',
      '[2001:dd8:1f70::bbb:de8:7648:6e8]',
      '[2001:de8:1f70::999:de8:7648:6e8]:100'
    ])

    expect(retval).to match_array([
      '100',
      '300',
      '900',
      '1234',
      '8989'
    ])
  end
end
