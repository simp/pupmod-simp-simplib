require 'spec_helper'

describe 'parse_hosts' do
  # IPv4
  it do
    retval = subject.call([
      'http://some.domain.net',
      'http://localhost.my.domain:8989',
      'https://localhost.my.domain:8990',
      'fuu.bar.baz',
      'my.example.net:900',
      'my.example.net:700'
    ].map(&:freeze))

    expect(retval).to match({
      'some.domain.net' => {
        :ports => [],
        :protocols => {
          'http' => []
        }
      },
      'localhost.my.domain' => {
        :ports => ['8989','8990'],
        :protocols => {
          'http'  => ['8989'],
          'https' => ['8990']
        }
      },
      'fuu.bar.baz' => {
        :ports     => [],
        :protocols => {}
      },
      'my.example.net' => {
        :ports => ['700','900'],
        :protocols=>{}
      }
    })
  end

  # IPv6
  it do
    retval = subject.call([
      'http://[2001:db8:1f70::999:de8:7648:001]:100',
      'https://[2001:db8:1f70::999:de8:7648:001]:200',
      'http://[2001:db8:1f70::999:de8:7648:002]',
      '[2001:db8:1f70::bbb:de8:7648:003]',
      '[2001:db8:1f70::999:de8:7648:004]:100',
      'http://2001:db8:1f70::999:de8:7648:005',
      '2001:db8:1f70::999:de8:7648:006'
    ])

    expect(retval).to match({
      '[2001:db8:1f70::999:de8:7648:001]' => {
        :ports => ['100','200'],
        :protocols => {
          'http' => ['100'],
          'https' => ['200']
        }
      },
      '[2001:db8:1f70::999:de8:7648:002]' => {
        :ports => [],
        :protocols => {
          'http' => []
        }
      },
      '[2001:db8:1f70::bbb:de8:7648:003]' => {
        :ports => [],
        :protocols => {}
      },
      '[2001:db8:1f70::999:de8:7648:004]' => {
        :ports => ['100'],
        :protocols => {}
      },
      '[2001:db8:1f70::999:de8:7648:005]' => {
        :ports => [],
        :protocols => {
          'http' => []
        }
      },
      '[2001:db8:1f70::999:de8:7648:006]' => {
        :ports => [],
        :protocols => {}
      }
    })
  end
end
