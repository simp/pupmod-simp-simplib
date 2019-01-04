require 'yaml'

module Facter; end

# Namespace for TPM2-related classes
#
# @see Facter::TPM2::Util Facter::TPM2::Util - Utilities for detecting and
#   reporting TPM 2.0 details
module Facter::TPM2; end

# Utilities for detecting and reporting TPM 2.0 information
#
# @note This class requires the following software to be installed on the
#   underlying operating system:
#   - `tpm2-tools` ~> 3.0 (tested with 3.0.3)
#   - (probably) `tpm2-abrmd` ~> 1.2 (tested with 1.2.0)
#   - `tpm2-tools` (and probably `tpm2-abrmd`) must be configured to access TPM
#
# @note TPM devices are assumed to follow the TCG PC Client PTP Specification
#   (https://trustedcomputinggroup.org/pc-client-platform-tpm-profile-ptp-specification/)
#
class Facter::TPM2::Util
  def initialize
    @prefix = Facter::TPM2::Util.tpm2_tools_prefix
  end

  # Facter executes a CLI command using the tpm2-tools path
  # @param [String] cmd The CLI command string for Facter to execute
  def exec(cmd)
    Facter.debug "executing '#{File.join(@prefix, cmd)}'"
    Facter::Core::Execution.execute(File.join(@prefix, cmd))
  end

  # Translate a TPM_PT_MANUFACTURER number into the TCG-registered ID strings
  #   (registry at: https://trustedcomputinggroup.org/vendor-id-registry/)
  #
  # @param  [Numeric] number to decode (from `TPM_PT_MANUFACTURER`)
  # @return [String] the decoded String
  def decode_uint32_string(num)
    # rubocop:disable Style/FormatStringToken
    # NOTE: Only strip "\x00" from the end of strings; some registered
    #       identifiers include trailing spaces (e.g., 'NSM ')!
    ('%x' % num).scan(/.{2}/).map { |x| x.hex.chr }.join.gsub(/\x00*$/,'')
    # rubocop:enable Style/FormatStringToken
  end

  # Converts two unsigned Integers in a 4-part version string
  def tpm2_firmware_version(tpm_pt_firmware_version_1,tpm_pt_firmware_version_2)
    # rubocop:disable Style/FormatStringToken
    s1 = ('%x' % tpm_pt_firmware_version_1).rjust(8,'0')
    s2 = ('%x' % tpm_pt_firmware_version_2).rjust(8,'0')
    # rubocop:enable Style/FormatStringToken
    (s1.scan(/.{4}/) + s2.scan(/.{4}/)).map{|x| x.hex }.join('.')
  end

  def tpm2_vendor_strings( tpm2_properties )
    [
       tpm2_properties['TPM_PT_VENDOR_STRING_1']['as string'],
       tpm2_properties['TPM_PT_VENDOR_STRING_2']['as string'],
       tpm2_properties['TPM_PT_VENDOR_STRING_3']['as string'],
       tpm2_properties['TPM_PT_VENDOR_STRING_4']['as string'],
    ]
  end


  # Decode properties that the TPM is required to provide, even in failure mode
  #
  # The property keys and values are made as human-readable as possible.
  # The firmware manufacturer string and version numbers are decoded into UTF-8
  # according to the TPM 2.0 specs and observed implementations.
  #
  # @param [Hash] properties, as collected by `tpm2_getcap -c properties-fixed`
  #
  # @return [Hash] Decoded
  def failure_safe_properties(fixed_props,variable_props)
    {
      'manufacturer'     => decode_uint32_string(
                              fixed_props['TPM_PT_MANUFACTURER']
                            ),
      'vendor_strings'   => tpm2_vendor_strings( fixed_props ),
      'firmware_version' => tpm2_firmware_version(
                              fixed_props['TPM_PT_FIRMWARE_VERSION_1'],
                              fixed_props['TPM_PT_FIRMWARE_VERSION_2']
                            ),
      'tpm2_getcap'      => { 'properties-fixed' => fixed_props, 'properties-variable' => variable_props }
    }
  end

  # Returns a structured fact describing the TPM 2.0 data
  # @return [nil] if TPM data cannot be retrieved.
  # @return [Hash] TPM2 properties
  def build_structured_fact

    # fail fast:
    unless @prefix                 # must have tpm2-tools installed
      Facter.debug 'path to tpm2-tools not found'
      return nil
    end

    unless exec('tpm2_pcrlist -s') # tpm2-tools must report on TPM
      Facter.debug 'no information returned from `tpm2_pcrlist -s`'
      return nil
    end

    # Get fixed properties
    yaml = exec('tpm2_getcap -c properties-fixed')
    properties_fixed = YAML.safe_load(yaml)
    #Get variable properties
    yaml = exec('tpm2_getcap -c properties-variable')
    properties_variable = YAML.safe_load(yaml)

    failure_safe_properties(properties_fixed, properties_variable)

  end

  # Returns the path of the tpm2-tools binaries
  # @return [String,nil] the first valid path found, or `nil` if no paths
  #                      were found.
  def self.tpm2_tools_prefix(paths = ['/usr/local/bin', '/usr/bin'])
    cmd = 'tpm2_pcrlist'
    tpm2_bin_path = nil
    paths.each do |path|
      if File.executable? File.join(path, cmd)
        tpm2_bin_path = path
        break
      end
    end
    tpm2_bin_path
  end
end
