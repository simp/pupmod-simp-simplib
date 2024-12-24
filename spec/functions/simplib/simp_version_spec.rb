#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::simp_version' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:simp_version_path) do
        if os_facts[:kernel].casecmp?('windows')
          'C:\ProgramData\SIMP\simp.version'
        else
          '/etc/simp/simp.version'
        end
      end

      context 'a valid version exists in simp.version' do
        before(:each) do
          allow(File).to receive(:read).with(any_args).and_call_original
          allow(File).to receive(:readable?).with(any_args).and_call_original
        end

        it 'returns the version with whitespace retained' do
          expect(File).to receive(:read).with(simp_version_path).and_return(" 6.4.0-0\n")
          expect(File).to receive(:readable?).with(simp_version_path).and_return(true)

          is_expected.to run.and_return(" 6.4.0-0\n")
        end

        it "returns the version with 'simp-' stripped" do
          expect(File).to receive(:readable?).with(simp_version_path).and_return(true)
          expect(File).to receive(:read).with(simp_version_path).and_return("simp-5.4.0-0\n")

          is_expected.to run.and_return("5.4.0-0\n")
        end

        it 'returns the version with whitespace stripped when stripping is enabled' do
          expect(File).to receive(:readable?).with(simp_version_path).and_return(true)
          expect(File).to receive(:read).with(simp_version_path).and_return("6.4.0-0\n")

          is_expected.to run.with_params(true).and_return('6.4.0-0')
        end
      end

      context 'simp.version is empty' do
        it 'returns unknown' do
          allow(File).to receive(:read).with(any_args).and_call_original
          expect(File).to receive(:read).with(simp_version_path).and_return('')
          expect(File).to receive(:readable?).with(simp_version_path).and_return(true)

          is_expected.to run.and_return("unknown\n")
        end
      end

      unless os_facts[:kernel].casecmp?('windows')
        context 'simp.version does not exist' do
          let(:rpm_query) do
            %q(PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null)
          end

          context 'rpm query succeeds' do
            it 'returns the version with whitespace retained' do
              expect(File).to receive(:readable?).with(simp_version_path).and_return(false)
              expect(Puppet::Util::Execution).to receive(:execute).with(rpm_query, { failonfail: true }).and_return("6.4.0-0\n")

              is_expected.to run.and_return("6.4.0-0\n")
            end

            it 'returns the version with whitespace stripped when stripping is enabled' do
              expect(File).to receive(:readable?).with(simp_version_path).and_return(false)
              expect(Puppet::Util::Execution).to receive(:execute).with(rpm_query, { failonfail: true }).and_return("6.4.0-0\n")

              is_expected.to run.with_params(true).and_return('6.4.0-0')
            end
          end

          context 'rpm query fails' do
            it 'returns unknown' do
              expect(File).to receive(:readable?).with(simp_version_path).and_return(false)
              expect(Puppet::Util::Execution).to receive(:execute).with(rpm_query, { failonfail: true }).and_raise(Puppet::ExecutionFailure, 'Failed')

              is_expected.to run.and_return("unknown\n")
            end
          end
        end
      end
    end
  end
end
