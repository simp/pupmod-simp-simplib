# Fails a compile if the client system is not compatible with the module's
# metadata.json
#
# @param module_name
#   The name of the module that should be checked
#
# @param match
#   The level at which to match the release number
#
#   * none  -> No match on release (default)
#   * full  -> Full release must match
#   * major -> Only the major release must match
#
function simplib::assert_metadata_os (
  String                      $module_name,
  Enum['none','full','major'] $match = 'none'
) {

  $metadata = load_module_metadata($module_name)

  if empty($metadata) {
    fail("Could not find metadata for '${module_name}'")
  }

  if !$metadata['operatingsystem_support'] or empty($metadata['operatingsystem_support']) {
    debug("'operatingsystem_support' was not found in '${module_name}'")
  }
  elsif !($facts['os']['name'] in $metadata['operatingsystem_support'].map |Simplib::Puppet::Metadata::OS_support $os_info| { $os_info['operatingsystem'] }) {
    fail("OS '${facts['os']['name']}' is not supported by '${module_name}'")
  }
  else {
    $metadata['operatingsystem_support'].each |Simplib::Puppet::Metadata::OS_support $os_info| {
      if $os_info['operatingsystem'] == $facts['os']['name'] {
        case $match {
          'none': {
            $result = true
          }
          'full': {
            if !($facts['os']['release']['full'] in $os_info['operatingsystemrelease']) {
              fail("OS '${facts['os']['name']}' version '${facts['os']['release']['full']}' is not supported by '${module_name}'")
            }
          }
          'major': {
            $_os_major_releases = $os_info['operatingsystemrelease'].map |$os_release| {
              split($os_release, '\.')[0]
            }


            if !($facts['os']['release']['major'] in $_os_major_releases) {
              fail("OS '${facts['os']['name']}' version '${facts['os']['release']['major']}' is not supported by '${module_name}'")
            }
          }
        }
      }
    }
  }
}
