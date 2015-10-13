module Puppet::Parser::Functions

  newfunction(:validate_umask, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the passed value is a valid umask string.

        Examples:

        $val = '0077'
        validate_umask($val) => OK

        $val = '0078'
        validate_umask($val) => BAD

    ENDHEREDOC

    unless Array(args).length == 1 then
      raise Puppet::ParseError, ("validate_umask() takes exactly one argument")
    end

    unless Array(args).first =~ /^[0-7]{3,4}$/
      raise Puppet::ParseError, ("'#{args}' is not a valid umask.")
    end

  end

end
