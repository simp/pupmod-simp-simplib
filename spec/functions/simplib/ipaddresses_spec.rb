#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ipaddresses' do
  # Mock out the Facts
  context "All Interfaces Have IP Addresses" do
    let(:facts) {{
      :interfaces     => 'eth0,eth1,lo',
      :ipaddress_eth0 => '1.2.3.4',
      :ipaddress_eth1 => '5.6.7.8',
      :ipaddress_lo   => '127.0.0.1'
    }}

    it 'should return an array with no empty or nil values' do
      expect { run.with_params('').delete_if{|x| x and x =~ /\S/}.to =~ [] }
    end
  end

  context "All Interfaces Do Not Have IP Addresses" do
    let(:facts) {{
      :interfaces     => 'eth0,eth1,lo',
      :ipaddress_eth0 => '1.2.3.4',
      :ipaddress_lo   => '127.0.0.1'
    }}

    it 'should return an array with no empty or nil values' do
      expect { run.with_params('').delete_if{|x| x and x =~ /\S/}.to =~ [] }
    end
  end

  context "The system has no interfaces" do
    let(:facts) {{ }}

    it 'should not raise an error' do
      expect { run.with_params('') }.not_to raise_error
    end
  end
end
