module Puppet::Parser::Functions
  newfunction(:validate_umask, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the passed `String` is a valid `umask`

    @example
      $val = '0077'
      validate_umask($val) => OK

      $val = '0078'
      validate_umask($val) => BAD

    @return [Nil]
    ENDHEREDOC

    function_simplib_deprecation(['validate_umask', 'validate_umask is deprecated, please use Simplib::Umask data type'])

    unless Array(args).length == 1
      raise Puppet::ParseError, ("validate_umask() takes exactly one argument")
    end

    unless Array(args).first =~ /^[0-7]{3,4}$/
      raise Puppet::ParseError, ("'#{args}' is not a valid umask.")
    end
  end
end
