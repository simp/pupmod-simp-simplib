#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::simp_version' do
  context 'a valid version exists in /etc/simp/simp.version' do
    it 'should return the version with whitespace retained' do
      File.expects(:read).with('/etc/simp/simp.version').returns(" 6.4.0-0\n")
      File.stubs(:readable?).with('/etc/simp/simp.version').returns(true)
      File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

      is_expected.to run.and_return(" 6.4.0-0\n")
    end

    it "should return the version with 'simp-' stripped" do
      File.stubs(:readable?).with('/etc/simp/simp.version').returns(true)
      File.stubs(:read).with('/etc/simp/simp.version').returns("simp-5.4.0-0\n")
      File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

      is_expected.to run.and_return("5.4.0-0\n")
    end

    it 'should return the version with whitespace stripped when stripping is enabled' do
      File.stubs(:readable?).with('/etc/simp/simp.version').returns(true)
      File.stubs(:read).with('/etc/simp/simp.version').returns("6.4.0-0\n")
      File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

      is_expected.to run.with_params(true).and_return('6.4.0-0')
    end
  end

  context '/etc/simp/simp.version is empty' do
    it 'should return unknown' do
      File.stubs(:read).with('/etc/simp/simp.version').returns("")
      File.stubs(:readable?).with('/etc/simp/simp.version').returns(true)
      File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

      is_expected.to run.and_return("unknown\n")
    end
  end

  context '/etc/simp/simp.version does not exist' do
    let(:rpm_query) do
      %q{PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null}
    end

    context 'rpm query succeeds' do
      it 'should return the version with whitespace retained' do
        File.stubs(:readable?).with('/etc/simp/simp.version').returns(false)
        Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).returns("6.4.0-0\n")

        is_expected.to run.and_return("6.4.0-0\n")
      end

      it 'should return the version with whitespace stripped when stripping is enabled' do
        File.stubs(:readable?).with('/etc/simp/simp.version').returns(false)
        Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).returns("6.4.0-0\n")

        is_expected.to run.with_params(true).and_return('6.4.0-0')
      end
    end

    context 'rpm query fails' do
      it 'should return unknown' do
        File.stubs(:readable?).with('/etc/simp/simp.version').returns(false)
        Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).raises(Puppet::ExecutionFailure, "Failed")
#        ({
#         :exitstatus => 2,
#         :stdout => "package simp is not installed\n"
#        })

        is_expected.to run.and_return("unknown\n")
      end
    end
  end
end
