# A strucured fact that return some facts about a TPM 2.0 TPM
#
# The fact will be nil if the tpm2-tools are either not available, or aren't
# configured to comminucate with the TPM
Facter.add( :tpm2 ) do

  #### NOTE: The confine below is intentionally commented out to explain why
  ####       we're not using it (or something like it), as we did with the `tpm`
  ####       fact.
  ####
  #### The `:has_tpm` detection strategy used for TPM 1 is unreliable for TPM
  #### 2.0.  TCTI can be configured to talk over different transports (including
  #### network sockets), so the TPM device the system is using may not be in a
  #### local `/dev/tmp#` device.
  ####
  #### This makes it impossible to conclusively detect whether a system has
  #### TPM2.0 capabilities until the tpm2-tools suite is installed and
  #### configured.
  ####
  #### See comments/discussion at:
  ####
  #### * https://github.com/pohly/intel-iot-refkit/commit/2fec96c0b129986c2657214dd68f44ef79615d3c
  #### * https://github.com/tpm2-software/tpm2-tools/issues/604
  ####
  #### As a consequence:
  ####
  #### * The `:has_tpm` fact from the original `tpm` module is *not* used to
  ####   confine TPM 2.0 facts.
  #### * Instead, the `:tpm2` fact returns information--only if it is available.
  #### * The `tpm_version` fact from the original `tpm` module *can* be used to
  ####   confine the tpm2 fact code *not* to run (if we have confirmed that the
  ####   system has a TPM 1.2 device, there is no sense in checking for TPM 2
  ####
  #### confine :has_tpm => true
  ###
  #### ^^^ NOTE: The confine above is intentionally commented out (see comments).


  # Confine the TPM2 fact to systems that are known NOT to have a TPM 1 device.
  #
  # This block is an optimization:
  #
  # It only makes sense to try to collect TPM2 info if either:
  # - If a local TPM device has *not* been detected (TCTI may use network)
  # - If a local TPM device has been detected, but is *not* TPM 1.2
  #
  # NOTE: This `confine` block *must* be anonymous--a direct confine on
  # `:tpm_version` will always short-circuit if that fact is absent. (Facter
  # doesn't execute confine blocks for absent facts.)
  confine do
    value = Facter.value(:tpm)
    Facter.debug 'tpm2 confine on tpm fact'
    value.nil?
  end

  confine do
    require 'facter/tpm2/util'
    Facter.debug 'tpm2 confine on tpm2-tools'
    !Facter::TPM2::Util.tpm2_tools_prefix.nil?
  end

  setcode do
    Facter.debug 'tpm2 setcode'
    require 'facter/tpm2/util'
    Facter::TPM2::Util.new.build_structured_fact
  end
end

