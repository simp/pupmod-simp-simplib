module Puppet::Parser::Functions
  newfunction(:validate_deep_hash, :doc => <<-'ENDDOC') do |args|
    Perform a deep validation on two passed hashes.

    The first hash is the one to validate against, and the second is
    the one being validated. The first hash (i.e. the source) exists
    to define a valid structure and potential regular expression to
    validate against, or nil top skip an entry. Arrays of values
    will match each entry to the given regular expression. Below are
    examples of a source hash and a hash to compare against it:

    'source' = {
       'foo' => {
         'bar' => {
           #NOTE: Use single quotes for regular expressions
           'baz' => '^\d+$',
           'abc' => '^\w+$',
           'def' => nil #NOTE: not 'nil' in quotes
         },
         'baz' => {
           'xyz' => '^true|false$'
         }
       }
     }

    'to_check' = {
       'foo' => {
         'bar' => {
           'baz' => '123',
           'abc' => [ 'these', 'are', 'words' ],
           'def' => 'Anything will work here!'
         },
         'baz' => {
           'xyz' => 'false'
         }
       }
     }

    And an example of a hash that would fail validation:

    'source' => { 'foo' => '^\d+$' }

    'to_check' => { 'foo' => 'abc' }

    This fails because we expect the value of 'foo' to be a series of
    digits, not letters.

    Additionally, all keys must be defined in the source hash that is being
    validated against. Unknown keys in the hash being compared will cause a
    failure in validation

    ENDDOC

    def self.deep_validate(source, to_check, level="TOP", invalid = Array.new)
      to_check.each do |k,v|
        #Step down a level if value is another hash
        if v.is_a?(Hash)
          src_key_hash = source[k]
          if src_key_hash != nil
            source[k].nil? or source[k] == 'nil' and next

            deep_validate(src_key_hash, v, level+"-->#{k}", invalid)
          else
            invalid << (level+"-->#{k} (No key for '#{k}')")
          end
        #Compare regular expressions since we are at the bottom level
        else
          regexp = source[k]

          source[k].nil? or regexp == 'nil' and next

          if not (regexp.is_a?(String) or regexp.is_a?(TrueClass) or regexp.is_a?(FalseClass)) then
            raise Puppet::ParseError, ("validate_deep_hash(): Regexp to check must be a string, got '#{regexp.class}'")
          end

          if ( to_check[k].is_a?(TrueClass) or to_check[k].is_a?(FalseClass) ) then
            to_check[k] = "#{to_check[k]}"
          elsif to_check[k].is_a?(String)
            if (Regexp.new(regexp).match(v) == nil) then
              invalid << level+"-->#{k} '#{to_check[k]}' must validate against '/#{regexp}/'"
            end
          elsif to_check[k].is_a?(Array)
            to_check[k].each do |x|
              if (Regexp.new(regexp).match(x) == nil) then
                invalid << level+"-->#{k} '[#{to_check[k].join(', ')}]' must all validate against '/#{regexp}/'"
                break
              end
            end
          else
            invalid << (level+"-->#{k} (Not a String or Array)")
          end
        end
      end
      return invalid
    end

    if args.length != 2 then
      raise Puppet::ParseError, ("validate_deep_hash(): wrong number of arguments (#{args.length}; must be 2)")
    end

    if not ( args[0].is_a?(Hash) and args[1].is_a?(Hash) ) then
      raise Puppet::ParseError, ("validate_deep_hash(): Both arguments must be hashes.")
    end

    invalid = deep_validate(args.first,args.last)
    if invalid.size > 0 then
      invalid.each do |entry|
        raise Puppet::ParseError,entry
      end
    end
  end
end
