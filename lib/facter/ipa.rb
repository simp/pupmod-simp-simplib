# _Description_
#
# Return a hash of IPA information:
# * status:
#   - 'joined' when the host is able to pull both the domain and IPA
#      server information from an IPA server
#   - 'unknown' when the host is not able to pull both the domain
#     and server information from an IPA server
# * domain: The IPA domain or nil, if the host is unable to pull the
#   domain information from the IPA server
# * server: The IPA server to which this host is connected or nil,
#   if the host is unable to pull the server information from the
#   IPA server
#
Facter.add(:ipa) do
  confine :kernel => 'Linux'

  kinit = Facter::Core::Execution.which('kinit')
  confine { kinit }

  ipa = Facter::Core::Execution.which('ipa')
  confine { ipa }

  # This file is only present if the host has, at some time,
  # been joined to an IPA domain.  Its presence, however, is
  # insufficient to tell us if the host is currently joined.
  # A host can be unprovisioned by the IPA server and still
  # retain this file.
  confine { File.exist?('/etc/ipa/default.conf') }

  setcode do
    # Obtain host Kerberos token so we can use IPA API
    kinit_msg = Facter::Core::Execution.exec("#{kinit} -k 2>&1")
    if kinit_msg.nil? or !kinit_msg.strip.empty?
      # Only messages emitted are error messages
      ipa_fact = { 'status' => 'unknown', 'domain' => nil, 'server' => nil }
    else
      # Use IPA API to determine this host's IPA server
      #
      # TODO: Just use 'ipa env server', once support for el6 is dropped.
      #       Unfortunately, this is not available on el6.
      host = Facter::Core::Execution.exec("#{ipa} env host")
      host = host.strip.split('host:')[1] unless host.nil?
      unless host.nil? or host.strip.empty?
        # 'ipa host-show' will prompt if no host is passed in...
        host_info = Facter::Core::Execution.exec("#{ipa} host-show #{host.strip}").to_s
        managed_line = host_info.split("\n").delete_if {
          |line| !line.include?('Managed by:')
        }
        server = managed_line.empty? ? nil : managed_line[0].strip.split('Managed by:')[1]
        server = nil if (server and server.strip.empty?)
      end

      # Use IPA API to retrieve domain from the client environment
      domain = Facter::Core::Execution.exec("#{ipa} env domain")
      domain = domain.strip.split('domain:')[1] unless domain.nil?
      domain = nil if (domain and domain.strip.empty?)

      if domain.nil? or server.nil?
        status = 'unknown'
      else
        status = 'joined'
      end
      domain.strip! unless domain.nil?
      server.strip! unless server.nil?
      ipa_fact = { 'status' => status, 'domain' => domain, 'server' => server }
    end

    ipa_fact
  end
end
