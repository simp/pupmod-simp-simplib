module Puppet::Parser::Functions
  # This function pulls a mapped value from a text file with the format:
  #
  # <key> | <value>
  #
  # The input to the fuction should be (<ruby regex>,<map file>).
  #
  # Only the last value matched will be returned

  newfunction(:mapval, :type => :rvalue, :doc => "Pull a mapped value from a text file.  Must provide a Ruby regex!.") do |args|
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
