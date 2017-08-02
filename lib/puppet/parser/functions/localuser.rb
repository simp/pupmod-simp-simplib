module Puppet::Parser::Functions
  newfunction(:localuser, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Pull a pre-set password from a password list and return an `array` of
    user details associated with the passed hostname.

    If the password starts with the string `$1$` and the length is `34`
    characters, then it will be assumed to be an `MD5` hash to be directly
    applied to the system.

    If the password is in plain text form, then it will be hashed and stored
    back into the source file for future use.  The plain text version will be
    commented out in the file.

    @example Password Line syntax

      [+-!]<fqdn-regex>,<username>,<uid>,<gid>,[<homedir>],<password>

    Lines beginning with the `#` symbol are ignored and commas `,` are not
    allowed in usernames or hostnames though any characters are allowed in
    passwords.

    `homedir` is the home directory of the user and is optional. By default,
    the system will choose the home directory.

    The function will return a `String` with the following contents:

    `[attr]<username>,MD5-based password hash with random salt`

    Hostname Ruby regular expressions are fully supported. The following
    formats are allowed:

      * /regex/opts,<username>
      * /regex/,<username>
      * regex,<username>
      * *.<domain>,<username>
      * fqdn,<username>

    @param filename [Stdlib::Absolutepath]
      path to the file containing the local users
    @param hostname
      host that you are trying to match against

    @return [String]
    ENDHEREDOC
    filename = args[0]
    hostname = args[1]
    retval = []

    if not FileTest.exists?("#{filename}") then
        return ["### You must have a file on the server at #{filename} from which to read usernames and hashes ###\n### These lines will be ignored ###\n"]
    end

    File.open(filename, 'r+') do |file|
      oldfile = file.readlines.map(&:chomp)

      oldfile.each_with_index do |line,index|

        # If it isn't a comment, do stuff.
        if ( line !~ /^#/ ) then

          host = hostname

          # Chunk the line, the first field is the regex.
          vals = line.split(',')

          orighost = vals.shift
          if ( orighost =~ /^([+-\\!]?)(.*)/ ) then
            extattr = $1
            orighost = $2
          end

          # Copy this to a variable for mangling
          orighost_tmp = orighost

          # This covers the legacy format, which could start with a '*'
          if ( orighost_tmp =~ /^\*/ ) then
              orighost_tmp = ".#{orighost_tmp}"
          end

          # If this is a formatted regex, treat it as such.
          if ( orighost_tmp =~ /^\// ) then
              orighost_tmp = orighost_tmp.split(/\//)
              hostregex = Regexp.new(orighost_tmp[1],orighost_tmp[2])
          else
              hostregex = Regexp.new("^#{orighost_tmp}$")
          end

          # Match against the passed hostname.
          if hostregex.match(host) then

            username = vals.shift
            uid = vals.shift
            gid = vals.shift
            homedir = nil
            if ( vals.length == 2 ) then
              homedir = vals.shift
            end
            pass = "#{vals.shift.chomp}"
            vals.each {|x| pass = pass + "," + x.chomp}

            # See if we already have a hashed pass.
            if ( pass =~ /\$[156]\$/ )
              hash = pass
            # If not, then create one.
            else
              chars = ("a".."z").to_a + ("0".."9").to_a + %w{. /}
              salt = "$6$rounds=10000$" + Array.new(8, '').collect{chars[rand(chars.size)]}.join

              hash = pass.crypt(salt)

              # Check to be sure that we got a hashed password.
              # We really should never get here on a modern system.
              if not hash.include?(salt) then
                # Fall back to MD5
                salt = "$1$" + Array.new(8, '').collect{chars[rand(chars.size)]}.join
                hash = pass.crypt(salt)
              end

              oldfile[index] = "# " + oldfile[index]
              if ( homedir ) then
                oldfile.insert(index+1, "#{extattr}#{orighost},#{username},#{uid},#{gid},#{homedir},#{hash}\n")
              else
                oldfile.insert(index+1, "#{extattr}#{orighost},#{username},#{uid},#{gid},#{hash}\n")
              end
            end
            if ( homedir ) then
              retval << "#{extattr}#{username},#{uid},#{gid},#{homedir},#{hash}"
            else
              retval << "#{extattr}#{username},#{uid},#{gid},#{hash}"
            end
          end
        end
      end
      file.pos = 0
      file.print oldfile.join("\n")
      file.truncate(file.pos)
      file.close
    end

    retval
  end
end
