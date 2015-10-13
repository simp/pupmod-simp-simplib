require 'spec_helper'

describe 'strip_ports' do
  # IPv4
  it do
    retval = scope.function_strip_ports([
      'rsync://127.0.0.1:1234',
      'http://some.domain.net',
      'http://some.domain.net',
      'http://localhost.my.domain:8989',
      'fuu.bar.baz',
      'my.example.net:900'
    ].map(&:freeze))

    expect(retval).to match_array([
      '127.0.0.1',
      'some.domain.net',
      'localhost.my.domain',
      'fuu.bar.baz',
      'my.example.net'
    ])
  end

  # IPv6
  it do
    retval = scope.function_strip_ports([
      'http://[2001:db8:1f70::999:de8:7648:001]:100',
      'http://[2001:db8:1f70::999:de8:7648:002]',
      '[2001:db8:1f70::bbb:de8:7648:003]',
      '[2001:db8:1f70::999:de8:7648:004]:100'
    ])

    expect(retval).to match_array([
      '[2001:db8:1f70::999:de8:7648:001]',
      '[2001:db8:1f70::999:de8:7648:002]',
      '[2001:db8:1f70::bbb:de8:7648:003]',
      '[2001:db8:1f70::999:de8:7648:004]'
    ])
  end
end
