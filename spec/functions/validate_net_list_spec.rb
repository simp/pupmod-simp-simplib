require 'spec_helper'

describe 'validate_net_list' do
  context 'IPv4' do
    describe 'valid IPv4 string' do
      it 'validates address-only' do
        expect { subject.call(['1.2.3.4']) }.to_not raise_error
      end

      it 'validates address plus port' do
        expect { subject.call(['1.2.3.4:5678']) }.to_not raise_error
      end

      it 'validates CIDR with numeric network mask' do
        expect { subject.call(['1.2.0.0/16']) }.to_not raise_error
      end

      it 'validates CIDR with quad-dotted network mask' do
        expect { subject.call(['1.2.0.0/255.255.0.0']) }.to_not raise_error
      end
    end

    describe 'invalid IPv4 string' do
      it 'rejects invalid octet' do
        expect { subject.call(['1.2.3.256']) }.to raise_error(Puppet::ParseError, /'1.2.3.256' is not a valid network/)
      end

      it 'rejects CIDR missing network mask' do
        pending "IPAddr allows empty network mask '1.2.3.4/'"
        expect { subject.call(['1.2.3.4/']) }.to raise_error
      end

      it 'rejects CIDR with invalid numeric network mask' do
        expect { subject.call(['1.2.3.4/33']) }.to raise_error(Puppet::ParseError, /'1.2.3.4\/33' is not a valid network/)
      end

      it 'rejects CIDR with invalid quad-dotted network mask' do
        expect { subject.call(['1.2.3.4/256.255.0.0']) }.to raise_error(Puppet::ParseError, /'1.2.3.4\/256.255.0.0' is not a valid network/)
      end

      it 'rejects invalid port' do
        expect { subject.call(['1.2.3.4:66000']) }.to raise_error(Puppet::ParseError, /'66000' is not a valid port/)
      end
    end
  end

  context 'IPv6' do
    describe 'valid IPv6 string' do
      it 'validates fully-specified, address-only' do
        expect { subject.call(['2001:0db8:85a3:0000:0000:8a2e:0370:7334']) }.to_not raise_error
      end

      it 'validates abbreviated, address-only' do
        expect { subject.call(['2001:0db8:85a3::0000:8a2e:0370:7334']) }.to_not raise_error
      end

      it 'validates address plus port' do
        expect { subject.call(['[2001:db8:a::]:64']) }.to_not raise_error
      end

      it 'validates CIDR with numeric network mask' do
        expect { subject.call(['2001:db8:a::/64']) }.to_not raise_error
      end

      it 'validates CIDR with hex network mask' do
        expect { subject.call(['2001:0db8:030a:4000:0360:ff00:0042:0000/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000']) }.to_not raise_error
      end
    end

    describe 'invalid IPv6 string' do
      it 'rejects invalid octet' do
        expect { subject.call(['20011:db8:a::']) }.to raise_error(Puppet::ParseError, /'20011:db8:a::' is not a valid network/)
      end

      it 'rejects CIDR missing network mask' do
        pending "IPAddr allows empty network mask '2001:db8:a::/'"
        expect { subject.call(['2001:db8:a::/']) }.to raise_error
      end

      it 'rejects CIDR with invalid numeric network mask' do
        expect { subject.call(['20011:db8:a::/129']) }.to raise_error(Puppet::ParseError, /'20011:db8:a::\/129' is not a valid network/)
      end

      it 'rejects CIDR with invalid hex network mask' do
        expect { subject.call(['2001:0db8:030a:4000:0360:ff00:0042:0000/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFFFFF:0000']) }.to raise_error(Puppet::ParseError, /'2001:0db8:030a:4000:0360:ff00:0042:0000\/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFFFFF:0000' is not a valid network/)
      end

      it 'rejects invalid port' do
        expect { subject.call(['[2001:db8:a::]:66000']) }.to raise_error(Puppet::ParseError, /'66000' is not a valid port/)
      end
    end
  end

  context 'hostname' do
    describe 'valid hostname string' do
      it 'validates hostname without domain' do
        expect { subject.call(['myhost']) }.to_not raise_error
      end

      it 'validates hostname with domain' do
        expect { subject.call(['myhost.test.local']) }.to_not raise_error
      end

      it 'validates hostname with domain and port' do
        expect { subject.call(['myhost.test.local:8080']) }.to_not raise_error
      end
    end

    describe 'invalid hostname string' do
      it 'rejects invalid hostname' do
        expect { subject.call(['my$bad$hostname']) }.to raise_error(Puppet::ParseError, /'my\$bad\$hostname' is not a valid network/)
      end

      it 'rejects invalid port' do
        expect { subject.call(['myhostname:-10']) }.to raise_error(Puppet::ParseError, /'-10' is not a valid port/)
      end
    end
  end

  context 'regex match' do
    describe 'valid match for pattern that cannot be a hostname' do
      it { expect { subject.call([['%any'], '%any']) }.to_not raise_error }
      it { expect { subject.call([['%any'], '^(%any|%none)$']) }.to_not raise_error }
      it { expect { subject.call([['case/requiring/escapes'], '^case\/requiring\/escapes$']) }.to_not raise_error }
      it { expect { subject.call([['*'], '\*']) }.to_not raise_error }
      it { expect { subject.call([['*'], '*']) }.to_not raise_error }
    end
  end

  context 'array' do
    describe 'valid array' do
      it 'validates when all elements are valid' do
        expect { subject.call([['1.2.3.4:5678', '[2001:db8:a::]:64', 'myhost']]) }.to_not raise_error
        expect { subject.call([['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host'], '^my\?host$']) }.to_not raise_error
      end
    end
 
    describe 'invalid array' do
     it 'rejects when any element is invalid' do
        expect { subject.call([['1.2.3.4:-10', '[2001:db8:a::]:64', 'myhost']]) }.to raise_error(Puppet::ParseError, /is not a valid/)
        expect { subject.call([['1.2.3.4:10', '[2001:db8:a ::]:64', 'myhost']]) }.to raise_error(Puppet::ParseError, /is not a valid/)
        expect { subject.call([['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host']]) }.to raise_error(Puppet::ParseError, /is not a valid/)
        expect { subject.call([['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host '], '^my\?host$']) }.to raise_error(Puppet::ParseError, /is not a valid/)
      end
    end
  end
end
