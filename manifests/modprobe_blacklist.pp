# == Class: simplib::modprobe_blacklist
#
# This class provides a default set of blacklist entries per the SCAP
# Security Guide.
#
# If you want to later enable a module, you simply need to create a
# file that comes after 00_simp_blacklist.conf in the /etc/modprobe.d
# directory.
#
# For example:
#   # Re-enable usb_storage
#   file { '/etc/modprobe.d/usb_storage':
#     owner   => 'root',
#     group   => 'root',
#     mode    => '0644',
#     content => 'install usb-storage /sbin/modprobe usb-storage'
#
# == Parameters
#
# [*enable*]
# Type: Boolean
# Default: true
#   If true, enable blacklisting. If false, disable blacklisting.
#   Full enforcement will require a reboot.
#
# [*blacklist*]
# Type: Array
# Default: [
#  'bluetooth',   # CCE-26763-3
#  'cramfs',      # CCE-26340-0
#  'dccp',        # CCE-26448-1
#  'dccp_ipv4',   # CCE-26448-1
#  'dccp_ipv6',   # CCE-26448-1
#  'freevxfs',    # CCE-26544-7
#  'hfs',         # CCE-26800-3
#  'hfsplus',     # CCE-26361-6
#  'ieee1394',
#  'jffs2',       # CCE-26670-0
#  'net-pf-31',   # CCE26763-3
#  'rds',         # CCE-26239-4
#  'sctp',        # CCE-26410-1
#  'squashfs',    # CCE-26404-4
#  'tipc',        # CCE-26696-5
#  'udf',         # CCE-26677-5
#  'usb-storage' # CCE-27016-5
# ]
#
# [*blacklist_method*]
# Type: Absolute Path
# Default: '/bin/true'
#  The application to use in order to blacklist the files. You probably want
#  /bin/true or /bin/false but this is left open to allow for custom blacklist
#  capabilities.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class simplib::modprobe_blacklist (
  $enable = true,
  $blacklist = [
    'bluetooth',
    'cramfs',
    'dccp',
    'dccp_ipv4',
    'dccp_ipv6',
    'freevxfs',
    'hfs',
    'hfsplus',
    'ieee1394',
    'jffs2',
    'net-pf-31',
    'rds',
    'sctp',
    'squashfs',
    'tipc',
    'udf',
    'usb-storage'
  ],
  $blacklist_method = '/bin/true'
){
  $blacklist_target = '/etc/modprobe.d/00_simp_blacklist.conf'

  if $enable {
    file { $blacklist_target:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => inline_template(
"# This file managed by Puppet.
<% @blacklist.each do |blist_item| -%>
install <%= blist_item %> <%= @blacklist_method %>
<% end -%>
"
      )
    }
  }
  else {
    file { $blacklist_target: ensure => 'absent' }
  }

  validate_array($blacklist)
  validate_absolute_path($blacklist_method)
}
