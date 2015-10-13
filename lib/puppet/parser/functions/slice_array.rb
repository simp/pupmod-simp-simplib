module Puppet::Parser::Functions
  newfunction(
    :slice_array,
    :type => :rvalue,
    :doc  => "Split an array into an array of arrays that contain groupings of
              'max_length' size. This is similar to 'each_slice' in newer
              versions of Ruby.

              * Options *

              to_slice => The array to slice. This will be flattened if
                          necessary.

              max_length => The maximum length of each slice.

              split_char => An optional character upon which to count
                            sub-elements as multiples. Only one per subelement
                            is supported."

  ) do |args|

    # Variable Assignment
    to_slice = args[0]
    max_length = args[1]
    split_char = args[2]

    # Input Validation
    if not to_slice then
      raise Puppet::ParseError.new("You must pass an array to slice as the first argument.")
    end

    if Array(to_slice).length == 0 then
      raise Puppet::ParseError.new("The array to slice must be of size > 0.")
    end

    if not max_length or max_length.to_s !~ /^\d+$/ then
      raise Puppet::ParseError.new("You must pass an integer as the second argument. Got: '#{max_length}'")
    end

    # Do the slicing
    max_length = max_length.to_i
    to_slice = Array(to_slice).flatten

    if split_char then
      cluster_locations = to_slice.collect{|x| x.to_s.include?(split_char)}

      to_slice = to_slice.map{|x| x.to_s.split(split_char)}.flatten
    end

    num_groups = to_slice.length/max_length
    to_slice.length % max_length != 0 and num_groups += 1

    retval = []
    (0...num_groups).each do |x|
      retval << to_slice[(x * max_length)..((x * max_length) + max_length - 1)].compact
    end

    if split_char then
      i = 0
      retval.each do |arr|
        arr.each_with_index do |x,j|
          if cluster_locations[i] then
            arr[j] = "#{arr[j]}:#{arr[j+1]}"
            arr.delete_at(j+1)
          end
          i += 1
        end
      end
    end

    retval
    end
end
