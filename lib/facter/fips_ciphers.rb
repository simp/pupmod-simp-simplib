# List available FIPS-compatible OpenSSL ciphers on the system
# Returns: Array[String]
Facter.add('fips_ciphers') do
  confine :kernel => 'Linux'

  setcode do
    Facter::Core::Execution.exec(`openssl ciphers FIPS:!LOW`).split(':')
  end
end
