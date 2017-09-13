
module Puppet::Parser::Functions
  newfunction(:rand_cron, :type => :rvalue, :arity => -1, :doc => <<-'ENDHEREDOC') do |args|
    Provides a 'random' value to `cron` based on the passed `Integer` value.

    Used to avoid starting a certain `cron` job at the same time on all
    servers.

    If used with no parameters, it will return a single value between `0-59`
    first argument is the occurrence within a timeframe, for example if you
    want it to run `2` times per hour the second argument is the timeframe,
    by default its `60` minutes, but it could also be `24` hours etc

    Based on: http://projects.puppetlabs.com/projects/puppet/wiki/Cron_Patterns/8/diff

      * Author: ohadlevy@gmail.com
      * License: None Posted

    @example

      int_to_cron('100')    - returns one value between 0..59 based on the value 100
      int_to_cron(100,2)    - returns an array of two values between 0..59 based on the value 100
      int_to_cron(100,2,24) - returns an array of two values between 0..23 based on the value 100

    @param modifier [String]
      Input range modifier

    @param occurs [Integer]
      How many values to return

    @param scope [Integer]
      Top range of randomly generated number

    @return [Variant[Integer[0,59], Array[Integer[0,59], Integer[0,23]]]]
    ENDHEREDOC

    function_simplib_deprecation(['rand_cron', 'rand_cron is deprecated, please use simplib::rand_cron'])
    modifier = Array(args[0]).flatten.first

    occurs   = (args[1] || 1).to_i
    scope    = (args[2] || 60).to_i

    # We're making a special case for IP Addresses since they are most
    # likely to be passed in here and you want to let them act
    # linearly.
    begin
      modifier = IPAddr.new(modifier).to_i
    rescue ArgumentError
      require 'zlib'
      modifier = Zlib.crc32("#{modifier}")
    end

    base    = modifier % scope

    if occurs == 1
      base
    else
      cron = Array.new
      (1..occurs).each do |i|
        cron << ((base - (scope / occurs * i)) % scope)
      end
      return cron.sort
    end
  end
end

