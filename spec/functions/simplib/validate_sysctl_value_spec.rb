require 'spec_helper'

describe 'simplib::validate_sysctl_value' do
  context 'with valid config' do

    it 'validates a kernel.core_pattern setting that is a filename' do
      is_expected.to run.with_params('kernel.core_pattern','/var/core/%u_%g_%p_%t_%h_%e.core')
    end

    it 'validates a kernel.core_pattern setting to pipe core to an fully qualified path' do
      is_expected.to run.with_params('kernel.core_pattern','| /usr/sbin/my_core_dump_program %p')
    end

    it 'accepts sysctl setting for which it does not have a validation routine' do
      is_expected.to run.with_params('net.ipv4.tcp_available_congestion_control','oops')
    end

  end

  context 'with invalid config' do
    it 'rejects a kernel.core_pattern setting that is too long' do
      is_expected.to run.with_params('kernel.core_pattern', '/var/core/'+ "x"*120).and_raise_error(
       /Values for kernel.core_pattern must be less than 129 characters/ )
    end

    it 'rejects an kernel.core_pattern setting that is pipe to an executable that does not have a fully-qualified path' do
      is_expected.to run.with_params('kernel.core_pattern', '| my_core_dump_program %p').and_raise_error(
       /Piped commands for kernel.core_pattern must have an absolute path/ )
    end
  end

end
