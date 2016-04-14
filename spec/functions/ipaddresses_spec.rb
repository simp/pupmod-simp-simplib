#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'ipaddresses' do
  # Mock out the Facts
  context "All Interfaces Have IP Addresses" do
    before :each do
      scope.stubs(:lookupvar).with("::interfaces").returns('eth0,eth1,lo')
      scope.stubs(:lookupvar).with("::ipaddress_eth0").returns('1.2.3.4')
      scope.stubs(:lookupvar).with("::ipaddress_eth1").returns('5.6.7.8')
      scope.stubs(:lookupvar).with("::ipaddress_lo").returns('127.0.0.1')
    end

    it 'should return an array with no empty or nil values' do
      expect { run.with_params('').delete_if{|x| x and x =~ /\S/}.to =~ [] }
    end
  end

  context "All Interfaces Do Not Have IP Addresses" do
    before :each do
      scope.stubs(:lookupvar).with("::interfaces").returns('eth0,eth1,lo')
      scope.stubs(:lookupvar).with("::ipaddress_eth0").returns('1.2.3.4')
      scope.stubs(:lookupvar).with("::ipaddress_eth1").returns('')
      scope.stubs(:lookupvar).with("::ipaddress_lo").returns('127.0.0.1')
    end

    it 'should return an array with no empty or nil values' do
      expect { run.with_params('').delete_if{|x| x and x =~ /\S/}.to =~ [] }
    end
  end

  context "The system has no interfaces" do
    before :each do
      scope.stubs(:lookupvar).with("::interfaces").returns('')
    end

    it 'should not raise an error' do
      #expect { scope.function_ipaddresses([]) }.not_to raise_error
      expect { run.with_params('') }.not_to raise_error
    end
  end
end
