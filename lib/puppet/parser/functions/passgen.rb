module Puppet::Parser::Functions
  newfunction(:passgen, :type => :rvalue, :doc => <<-EOM) do |args|
    Generates a random password string for a passed identifier.

    Uses `Puppet[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`
    as the destination directory.

    The minimum length password that this function will return is `6`
    characters.

      Arguments: identifier, <modifier hash>; in that order.

    @param identifier [String]
      Unique `String` to identify the password usage

    @param modifier_hash [Hash]
      May contain any of the following options:

        * `last` => `false`(*) or `true`
           * Return the last generated password

        * `length` => `Integer`
           * Length of the new password

        * `hash` => `false`(*), `true`, `md5`, `sha256` (true), `sha512`
           * Return a `Hash` of the password instead of the password itself.

        * `complexity` => `0`(*), `1`, `2`
          * `0` => Use only Alphanumeric characters in your password (safest)
          * `1` => Add reasonably safe symbols
          * `2` => Printable ASCII

        **private options:**

        * `password` => contains the string representation of the password to hash (used for testing)
        * `salt` => contains the string literal salt to use (used for testing)
        * `complex_only` => use only the characters explicitly added by the complexity rules (used for testing)

      If no, or an invalid, second argument is provided then it will return
      the currently stored `String`.

    @return [String]
    EOM
        require 'etc'
        require 'timeout'

        function_simplib_deprecation(['passgen', 'passgen is deprecated, please use simplib::passgen'])

        class SymbolicFileMode
          require 'puppet/util/symbolic_file_mode'
          include Puppet::Util::SymbolicFileMode
        end

        sym_filemode_processor = SymbolicFileMode.new

        puppet_user = 'puppet'
        puppet_user = Puppet[:user] if Puppet[:user]
        puppet_group = 'puppet'
        puppet_group = Puppet[:group] if Puppet[:group]

        @crypt_map = {
          'md5'     => '1',
          'sha256'  => '5',
          'sha512'  => '6'
        }

        @default_password_length = 32

        @id = args.shift
        arg_options = args.shift
        options = {
          'return_current' => false,
          'last'           => false,
          'length'         => @default_password_length,
          'hash'           => false,
          'complexity'     => 0,
          'complex_only'   => false,
        }

        # Convert legacy format to new hash format for options.
        if [String,Fixnum,Integer].include?(arg_options.class)
          if arg_options =~ /^l/
            options['last'] = true
          else
            options['length'] = arg_options.to_s
          end
        elsif arg_options.class == Hash
          options = options.merge(arg_options)
        else
          options['return_current'] = true
        end

        if options['length'].to_s !~ /^\d+$/
          raise Puppet::ParseError, "Error: Length must be an integer!"
        end

        if options['complexity'].to_s !~ /^\d+$/
          raise Puppet::ParseError, "Error: Complexity must be an integer!"
        end

        options['length'] = options['length'].to_i
        options['complexity'] = options['complexity'].to_i

        # Make sure a valid hash was passed if one was passed.
        if options['hash'] == true
          options['hash'] = 'sha256'
        end
        if options['hash'] and !@crypt_map.keys.include?(options['hash'])
          raise Puppet::ParseError, "Error: '#{options['hash']}' is not a valid hash."
        end

        passwd = ''
        salt = ''
        def self.gen_random_pass(length,complexity,complex_only)

            length = length.to_i
            if length.eql?(0)
                length = @default_password_length
            elsif length < 8
                length = 8
            end

            passwd = ''
            begin
                Timeout::timeout(30) do
                  default_charlist = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                  specific_charlist = nil
                  case complexity
                  when 1
                    specific_charlist = ['@','%','-','_','+','=','~']
                  when 2
                    specific_charlist = (' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a
                  else
                  end
                  unless specific_charlist == nil
                      if complex_only == true
                         charlists = [
                             specific_charlist
                         ]
                      else
                         charlists = [
                            default_charlist,
                            specific_charlist
                         ]
                      end

                  else
                      charlists = [
                          default_charlist
                      ]
                  end

                  charlists.each do |charlist|
                    (length/charlists.length).ceil.times { |i|
                      passwd += charlist[rand(charlist.size-1)]
                    }
                  end

                  passwd = passwd[0..(length-1)]
                end
            rescue Timeout::Error
                raise Puppet::ParseError, "passgen timed out for #{@id}!"
            end

            return passwd
        end


        if !@id
            raise Puppet::ParseError, "Please enter an identifier!"
        end

        if ($PASSGEN_testdir == nil)
          keydir = "#{Puppet[:vardir]}/simp/environments/#{lookupvar('::environment')}/simp_autofiles/gen_passwd"
        else
          keydir = "#{$PASSGEN_testdir}/gen_passwd"
        end

        if ( !File.directory?(keydir) )
            begin
                FileUtils.mkdir_p(keydir,{:mode => 0750})
                # This chown is applicable as long as it is applied
                # by puppet, not puppetserver.
                FileUtils.chown(puppet_user,puppet_group,keydir)
            rescue
                raise Puppet::ParseError, "Could not make directory #{keydir}. Ensure that #{File.dirname(keydir)} is writable by '#{puppet_user}'"
                return passwd
            end
        end

        # Here, we're trying to get the last entry, if it exists.  If it
        # doesn't, then just return the current entry, or throw an error if that
        # one doesn't exist. It's quite likely that you have something out of
        # order in the calling manifest if an error is thrown.
        if options['last']
            toread = nil
            if File.exists?("#{keydir}/#{@id}.last")
                toread = "#{keydir}/#{@id}.last"
            else
                toread = "#{keydir}/#{@id}"
            end

            if File.exists?(toread)
                passwd = IO.readlines(toread)[0].to_s.chomp
                sf = "#{File.dirname(toread)}/#{File.basename(toread,'.last')}.salt.last"
                saltfile = File.open(sf,'a+',0640)
                if saltfile.stat.size.zero?
                    if options.key?('salt')
                        salt = options['salt']
                    else
                        salt = self.gen_random_pass(16,0, options['complex_only'])
                    end
                    saltfile.puts(salt)
                    saltfile.close
                end
                salt = IO.readlines(sf)[0].to_s.chomp
            else
                Puppet.warning "Could not find a primary or 'last' file for #{@id}, please ensure that you have included this function in the proper order in your manifest!"
                if options.key?('password')
                    passwd = options['password']
                else
                    passwd = self.gen_random_pass(@default_password_length,options['complexity'], options['complex_only'])
                end
            end
        else
            # If the target file doesn't exist or the length of the password that
            # was read from the file is not equal to the length of the expected
            # password, then build a new password file.
            #
            # If no options were passed, and the file exists, then just throw
            # back the value in the file.  If the file is empty, create the new
            # password anyway.
            #
            # Rotate if you're creating a new password.
            #
            # Add an associated 'salt' file for returnting crypted passwords.

            # Open the file in append + read mode to prepare for what is to
            # come.

            tgt = File.new("#{keydir}/#{@id}","a+")
            tgt_hash = File.new("#{tgt.path}.salt","a+")
            # These chowns are applicable as long as they are applied
            # by puppet, not puppetserver.
            FileUtils.chown(puppet_user,puppet_group,tgt.path)
            FileUtils.chown(puppet_user,puppet_group,tgt_hash.path)

            # Create this if not there no matter what just in case we have an
            # upgraded system.
            if tgt_hash.stat.size.zero?
                if options.key?('salt')
                    salt = options['salt']
                else
                    salt = self.gen_random_pass(16,0, options['complex_only'])
                end
                tgt_hash.puts(salt)
                tgt_hash.rewind
            end

            if tgt.stat.size.zero?
                if options.key?('password')
                    passwd = options['password']
                else
                    passwd = self.gen_random_pass(options['length'],options['complexity'], options['complex_only'])
                end
                tgt.puts(passwd)
            else
                passwd = tgt.gets.chomp
                salt = tgt_hash.gets.chomp

                if !options['return_current'] and passwd.length != options['length'].to_i
                  tgt_last = File.new("#{tgt.path}.last","w+")
                  tgt_last.puts(passwd)
                  tgt_last.chmod(0640)
                  tgt_last.flush
                  tgt_last.close

                  tgt_hash_last = File.new("#{tgt_hash.path}.last","w+")
                  tgt_hash_last.puts(salt)
                  tgt_hash_last.chmod(0640)
                  tgt_hash_last.flush
                  tgt_hash_last.close

                  tgt.rewind
                  tgt.truncate(0)
                  passwd = self.gen_random_pass(options['length'],options['complexity'], options['complex_only'])
                  salt = self.gen_random_pass(16,options['complexity'], options['complex_only'])
                  tgt.puts(passwd)
                  tgt_hash.puts(salt)
                end
            end

            tgt.chmod(0640)
            tgt.flush
            tgt.close

        end

        # Ensure that the password space is readable and writable by the Puppet
        # user and no other users.

        unowned_files = []
        Find.find(keydir) do |file|
          file_stat = File.stat(file)

          # Do we own this file?
          begin
            file_owner = Etc.getpwuid(file_stat.uid).name

            unowned_files << file unless (file_owner == puppet_user)
          rescue ArgumentError => e
            debug("Error getting UID for #{file}: #{e}")

            unowned_files << file
          end

          # Ignore any file/directory that we don't own
          Find.prune if unowned_files.last == file

          FileUtils.chown(puppet_user,puppet_group,file)

          file_mode = file_stat.mode
          desired_mode = sym_filemode_processor.symbolic_mode_to_int('u+rwX,g+rX,o-rwx',file_mode,File.directory?(file))
          unless (file_mode & 007777) == desired_mode
            FileUtils.chmod(desired_mode,file)
          end
        end

        unless unowned_files.empty?
          err_msg = <<-EOM.gsub(/^\s+/,'')
            Error: Could not verify ownership by '#{puppet_user}' on the following files:
            * #{unowned_files.join("\n* ")}
          EOM
          raise Puppet::ParseError, err_msg
        end

        # Return the hash, not the password
        if options['hash']
          return passwd.crypt("$#{@crypt_map[options['hash']]}$#{salt}")
        else
          return passwd
        end
    end
end
