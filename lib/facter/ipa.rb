# _Description_
#
# Return a hash of IPA information:
# * status:
#   - 'joined' when the host is able to pull both the domain and IPA
#      server information from an IPA server
#   - 'unknown' when the host is not able to pull both the domain
#     and server information from an IPA server.  This status can
#     occur when connectivity to the IPA server is down or the
#     host has been unprovisioned at the IPA server and thus is
#     no longer joined to the configured IPA domain.
# * domain: The IPA domain or nil, if the host is unable to pull the
#   domain information from the IPA server
# * server: The IPA server to which this host is connected or nil,
#   if the host is unable to pull the server information from the
#   IPA server
# * default_domain:  The configured IPA domain from the domain setting
#     in /etc/ipa/default.conf.
# * default_server:  The nominal, configured IPA server extracted from
#     the xmlrpc_uri setting in /etc/ipa/default.conf.
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
    ipa_fact = {}
    defaults = IO.readlines('/etc/ipa/default.conf')
    defaults.each do |line|
      domain_match = line.match(/^domain\s*=\s*(\S*)/)
      if domain_match
        ipa_fact['default_domain'] = domain_match[1]
      end

      server_match = line.match(/^xmlrpc_uri\s*=\s*http[s]?:\/\/(\S*)\/ipa\/xml/)
      if server_match
        ipa_fact['default_server'] = server_match[1]
      end
      break if ipa_fact['default_domain'] and ipa_fact['default_server']
    end

    # Obtain host Kerberos token so we can use IPA API
    kinit_msg = Facter::Core::Execution.exec("#{kinit} -k 2>&1")
    if kinit_msg.nil? or !kinit_msg.strip.empty?
      # Only messages emitted are error messages
      ipa_fact.merge!({ 'status' => 'unknown', 'domain' => nil, 'server' => nil })
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
      ipa_fact.merge!({ 'status' => status, 'domain' => domain, 'server' => server })
    end

    ipa_fact
  end
end
