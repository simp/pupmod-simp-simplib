# vim: set expandtab ts=2 sw=2:
Puppet::Functions.create_function(:'simplib::filtered') do
  dispatch :filtered do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end
  dispatch :filtered_lookup_key do
    param 'String', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end
  def filtered(options, context)
    backend = call_function(options["function"], options, context)
    data = {}
    backend.each do |key, value|
      check_filter(key, options["filter"]) do |nkey|
        data[nkey] = value
      end
    end
    data
  end
  def filtered_lookup_key(key, options, context)
    retval = nil
    check_filter(key, options["filter"]) do |key|
      retval = call_function(options["function"], key, options, context)
      if (retval == nil)
        context.not_found
      end
    end
    if (retval == nil)
      context.not_found
    else
      retval
    end
  end
  def check_filter(key, filter, &block)
    filtered = false
    filter.each do |keyname|
      if (key =~ Regexp.new(keyname))
        filtered = true
      end
    end
    if (filtered == false)
      yield key
    end
  end
end
