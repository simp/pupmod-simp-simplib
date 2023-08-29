# _Description_
#
# Return a hash of IPA information, when the host has joined an IPA domain:
# * connected: Boolean value based on whether or not an IPA server
#     could be reached
#
# * domain: The IPA domain for which this host is configured
#
# * server: The IPA server for which this host is configured
#
# * realm: The Kerberos realm for the host
#
# * basedn:  The base DN for the IPA Directory
#
# * tls_ca_cert: The location of the IPA server's TLS CA Certificate if
#     the system is an IPA server
#
# Returns nil otherwise
#
Facter.add(:ipa) do
  confine :kernel => 'Linux'

  kinit = Facter::Core::Execution.which('kinit')
  confine { kinit }

  klist = Facter::Core::Execution.which('klist')
  confine { klist }

  ipa = Facter::Core::Execution.which('ipa')
  confine { ipa }

  truecmd = Facter::Core::Execution.which('true')
  confine { truecmd }

  # In EL8 the ipa command needs LC_ALL set to UTF-8 and this is the only
  # workaround at this time
  locale = ENV.fetch('LANG', 'en_US.UTF-8')
  locale = 'en_US.UTF-8' unless locale.match?(/UTF-?8/i)
  ipacmd = "#{truecmd} && LC_ALL=#{locale} #{ipa}"

  # This file is only present if the host has, at some time,
  # been joined to an IPA domain.
  confine { File.exist?('/etc/ipa/default.conf') }

  setcode do
    needed_keys = [
      'domain',
      'server',
      'realm',
      'basedn',
      'tls_ca_cert'
    ]

    file_defaults = File.read('/etc/ipa/default.conf').lines.
      map(&:strip).
      map{ |x|
        x.split(/\s*=\s*(.*)/)
      }.delete_if{|x|
        x.size < 2
      }.flatten

    ipa_timeout = 30
    kinit_timeout = 10

    defaults = Hash[*file_defaults]

    defaults.delete_if { |k,v| !needed_keys.include?(k) }

    # We won't know if we are connected to a server until later
    defaults['connected'] = false

    klist_retval = Puppet::Util::Execution.execute("#{klist} -s")
    unless klist_retval.exitstatus.zero?
      # Obtain host Kerberos token so we can use IPA API
      kinit_msg = Facter::Core::Execution.execute("#{kinit} -k 2>&1", options = {:timeout => kinit_timeout})
    end

    # Grab the necessary information from 'ipa env'
    ipa_response = Facter::Core::Execution.execute("#{ipacmd} env #{needed_keys.join(' ')}", options = {:timeout => ipa_timeout})

    if ipa_response.strip.empty?
      ipa_response = {}
    else
      ipa_server_response = Facter::Core::Execution.execute("#{ipacmd} env --server host", options = {:timeout => ipa_timeout})

      defaults['connected'] = !ipa_server_response.strip.empty?

      ipa_response = ipa_response.lines.grep(/\S:\s*.+/).map(&:strip).
        map{ |x|
          x.split(/:\s+(.*)/)
        }.flatten

      ipa_response = Hash[*ipa_response]

      ipa_response.keys.each do |key|
        # Some patch up work for EL6
        if key =~ /^<(.+)>$/
          ipa_response[$1] = ipa_response.delete(key)
        end
      end
    end

    defaults.merge(ipa_response)
  rescue => e
    Facter.warn(e)
  end
end
