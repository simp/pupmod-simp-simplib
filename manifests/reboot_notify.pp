# This is a simple controller class for global settings related to the
# 'reboot_notify' custom type
#
# @param log_level
#   The Puppet log_level to use when generating output
#
class simplib::reboot_notify (
  Simplib::PuppetLogLevel $log_level = 'notice'
){
  reboot_notify { '__simplib_control__':
    log_level    => $log_level,
    control_only => true
  }
}
