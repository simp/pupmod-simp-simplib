module Puppet::Parser::Functions
  # This function takes a whitespace delimited list of IP addresses and/or
  # hosts and returns true if an interface on the client system, or the fqdn or
  # short name of the host, is in that list.

  newfunction(
    :host_is_me,
    :type => :rvalue,
    :doc => "Detect if a local system identifier Hostname/IP address is contained in
             the passed whitespace delimited list. Whitespace and comma delimiters
             and passed arrays are accepted. 127.0.0.1 and ::1 are never matched,
             use 'localhost' or 'localhost6' for that if necessary."
  ) do |args|

    if args == '!test!' then return true end

    retval = false

    host_identifiers = [
      lookupvar("::fqdn"),
      lookupvar("::hostname"),
      'localhost',
      'localhost.localdomain',
      'localhost6',
      'localhost6.localdomain6'
    ]

    Puppet::Parser::Functions.autoloader.loadall
    lookupvar('::interfaces').split(',').each do |iface|
      iface_ipaddr = lookupvar("::ipaddress_#{iface}")
      next if "#{iface_ipaddr}".empty? or "#{iface_ipaddr}" =~ /undefined/i

      naked_iface = function_strip_ports(Array(iface_ipaddr))
      if naked_iface.is_a?(Array) and not naked_iface.first.nil? then
        host_identifiers.push(naked_iface.first)
      end
    end
    host_identifiers.delete('127.0.0.1')
    host_identifiers.delete('::1')

    to_check = args.dup

    if to_check.class == Array and to_check.size == 1 then
      to_check = to_check.first
    end

    if to_check.class != Array then
      to_check = to_check.split(/\s|,/).compact.delete_if { |x| x.empty? }
    end

    to_check.each do |id|
      if host_identifiers.include?(id) then
        retval = true
        break
      end
    end

    retval
  end
end
