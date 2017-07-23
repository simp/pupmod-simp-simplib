module Puppet::Parser::Functions
  newfunction(:deep_merge, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Perform a deep merge on two passed `Hashes`.

    This code is shamelessly stolen from the guts of
    `ActiveSupport::CoreExtensions::Hash::DeepMerge` and munged together with
    the Puppet Labs `stdlib` `merge()` function.

    @return [Hash]
    ENDHEREDOC

    def self.deep_merge(h1,h2)
      h1.merge(h2) do |key, oldval, newval|
        oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
        newval = newval.to_hash if newval.respond_to?(:to_hash)
        oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? deep_merge(oldval,newval) : newval
      end
    end

    if args.length < 2
      raise Puppet::ParseError, ("merge(): wrong number of arguments (#{args.length}; must be at least 2)")
    end

    if not ( args[0].is_a?(Hash) and args[1].is_a?(Hash) ) then
      raise Puppet::ParseError, ("validate_deep_hash(): Both arguments must be hashes.")
    end

    deep_merge(args.first,args.last)
  end
end
