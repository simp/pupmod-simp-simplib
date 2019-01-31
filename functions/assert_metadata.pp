# Fails a compile if the client system is not compatible with the module's
# `metadata.json`
#
# @param module_name
#   The name of the module that should be checked
#
# @param options
#   Behavior modifiers for the function
#   * Can be set using `simplib::assert_metadata::options` in the `lookup`
#     stack
#
#   **Options**
#
#   * enable => If set to `false` disable all validation
#   * os
#       * validate => Whether or not to validate the OS settings
#       * options
#           * release_match
#             * none  -> No match on minor release (default)
#             * full  -> Full release must match
#             * major -> Only the major release must match
#
# @return [None]
#
function simplib::assert_metadata (
  String[1] $module_name,
  Optional[Struct[{
    enable => Optional[Boolean],
    os     => Optional[Struct[{
      validate => Optional[Boolean],
      options  => Struct[{
        release_match => Enum['none','full','major']
      }]
    }]]
  }]]       $options = simplib::lookup('simplib::assert_metadata::options', { 'default_value' => undef }),
) {

  $_default_options = {
    'enable' => true,
    'os'     => {
      'validate' => true,
      'options' => {
        'release_match' => 'none'
      }
    }
  }

  if $options {
    $_options = deep_merge($_default_options, $options)
  }
  else {
    $_options = $_default_options
  }

  if $_options['enable'] {

    $metadata = load_module_metadata($module_name)

    if empty($metadata) {
      fail("Could not find metadata for '${module_name}'")
    }

    if $_options['os']['validate'] {
      if !$metadata['operatingsystem_support'] or empty($metadata['operatingsystem_support']) {
        debug("'operatingsystem_support' was not found in '${module_name}'")
      }
      elsif !($facts['os']['name'] in $metadata['operatingsystem_support'].map |Simplib::Puppet::Metadata::OS_support $os_info| { $os_info['operatingsystem'] }) {
        fail("OS '${facts['os']['name']}' is not supported by '${module_name}'")
      }
      else {
        $metadata['operatingsystem_support'].each |Simplib::Puppet::Metadata::OS_support $os_info| {
          if $os_info['operatingsystem'] == $facts['os']['name'] {
            case $_options['os']['options']['release_match'] {
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
              default: {
                $result = true
              }
            }
          }
        }
      }
    }
  }
}
