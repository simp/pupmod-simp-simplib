module Puppet::Parser::Functions
  newfunction(:mapval, :type => :rvalue, :doc => <<-EOM) do |args|
    This function pulls a mapped value from a text file with the format:

    `<key> | <value>`

    Only the **last** value matched will be returned

    @param regex [String]
      Ruby regular expression that will be mapped.
      Do not add starting `^` or ending `$`

    @param filename [Stdlib::Absolutepath]
      The filename from which to pull the value

    @return [String]
    EOM

    regex = args[0]
    filename = args[1]
    retval = ''
    File.open(filename, 'r') do |file|
      while line = file.gets
        line.chomp
        line = line.split(" | ")
        if ( line[0] =~ /^#{regex}$/ )
          line.shift
          retval = line.join.to_s.chomp
        end
      end
    end

    retval
  end
end
