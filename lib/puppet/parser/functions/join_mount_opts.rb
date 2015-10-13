module Puppet::Parser::Functions
  newfunction(
    :join_mount_opts,
    :type => :rvalue,
    :doc  => "Merge two sets of 'mount' options in a reasonable fashion.
              The second set will always override the first."
  ) do |args|

    # Input Validation
    if not args[0].is_a?(Array) or not args[1].is_a?(Array) then
      raise Puppet::ParseError.new("You must pass two arrays to join!")
    end

    # Variable Assignment
    system_opts = args[0].flatten.map(&:strip)
    new_opts = args[1].flatten.map(&:strip)

    # Remove any items that have a corresponding 'no' item in the
    # list. Such as 'dev' vs 'nodev', etc...
    system_opts.delete_if{|x|
      new_opts.include?("no#{x}")
    }
    # Reverse this if the user wants to explicitly set an option and a no*
    # option is already present.
    system_opts.delete_if{|x|
      found = false
      if x =~ /^no(.*)/ then
        found = new_opts.include?($1)
      end

      found
    }

    mount_options = {}

    if !lookupvar('::selinux_current_mode') or lookupvar('::selinux_current_mode') == 'disabled' then
      # SELinux is off, get rid of selinux related items in the
      # new_opts.
      system_opts.delete_if{|x| x =~ /^(((fs|def|root)?context=)|seclabel)/ }
      new_opts.delete_if{|x| x =~ /^(((fs|def|root)?context=)|seclabel)/ }
    else
      # Remove any SELinux context items if 'seclabel' is set. This
      # means that we can't remount it with new options.
      if system_opts.include?('seclabel') then
        # These two aren't compatible for remounts and can cause
        # issues unless done *very* carefully.
        system_opts.delete_if{|x| x =~ /^(fs|def|root)?context=/ }
        new_opts.delete_if{|x| x =~ /^(fs|def|root)?context=/ }
      end
    end

    (system_opts + new_opts).each do |opt|
      k,v = opt.split('=')
      if v and v.include?('"\'') then
        v.delete('"\'')
        # Anything with a comma must be double quoted!
        v = '"' + v + '"' if v.include?(',')
      end
      mount_options[k] = v
    end

    retval = []
    mount_options.keys.sort.each do |k|
      if mount_options[k] then
        retval << "#{k}=#{mount_options[k]}"
      else
        retval << k
      end
    end

    retval.join(',')
  end
end
