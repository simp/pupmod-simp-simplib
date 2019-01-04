# create "tpm_1_2_enabled" custom puppet fact
Facter.add("tpm_1_2_enabled") do
  confine :kernel => 'Linux'
  confine { Facter::Core::Execution.which('tpm_version') }
  setcode do
    # check whether tpm 1.2 is enabled
    tpm_1_2_version = Facter::Util::Resolution.exec('tpm_version')
    tpm_1_2_version.include? 'TPM 1.2 Version Info'
  end
end
