module Puppet::Parser::Functions
  newfunction(:validate_uri_list, :arity => -1, :doc => <<-'ENDHEREDOC') do |args|
    Usage: validate_uri_list([LIST],[<VALID_SCHEMES>])

    Validate that a passed list (`Array` or single `String`) of URIs is
    valid according to Ruby's URI parser.

    @example Passing
      $uris = ['http://foo.bar.baz:1234','ldap://my.ldap.server']
      validate_uri_list($uris)

      $uris = ['ldap://my.ldap.server','ldaps://my.ldap.server']
      validate_uri_list($uris,['ldap','ldaps'])

    @return [Nil]
    ENDHEREDOC

    function_simplib_deprecation(['validate_uri_list', 'validate_uri_list is deprecated, please use simplib::validate_uri_list'])

    uri_list = Array(args.shift)
    scheme_list = Array(args.shift)

    uri_list.each do |uri|
      begin
        require 'uri'
        uri_obj = URI(uri)

        unless scheme_list.empty?
          unless scheme_list.include?(uri_obj.scheme)
            raise Puppet::ParseError, ("validate_uri_list(): Scheme '#{uri_obj.scheme}' must be one of '#{scheme_list.join(',')}'")
          end
        end
      rescue URI::InvalidURIError
        raise Puppet::ParseError, ("validate_uri_list(): '#{uri}' is not a valid URI")
      end
    end
  end
end
