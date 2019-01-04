# create "tpm_2_0_enabled" custom puppet fact
Facter.add("tpm_2_0_enabled") do
  confine :kernel => 'Linux'
  confine { Facter::Core::Execution.which('tpm2_getcap') }
  setcode do
    # check whether tpm is enabled
    tpm_2_0_fixed_params = Facter::Util::Resolution.exec('tpm2_getcap -c properties-fixed')
    tpm_2_0_fixed_params.include? '"2.0"'
  end
end

