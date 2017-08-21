# Function to print deprecation warnings, logging a warning once
# for a given key.
#
# Messages can be suppressed if the SIMPLIB_LOG_DEPRECATIONS
# environment is set to 'false'
#
Puppet::Functions.create_function(:'simplib::deprecation') do

  # @param key Uniqueness key, which is used to dedupe of messages.
  # @param message Message to be printed, to which file and line
  #   information will be appended, if available.
  # @return [Nil]
  dispatch :deprecation do
    required_param 'String', :key
    required_param 'String', :message
  end

  def deprecation(key, message)
    if defined? Puppet::Pops::PuppetStack.stacktrace()
      stacktrace = Puppet::Pops::PuppetStack.stacktrace()
      file = stacktrace[0]
      line = stacktrace[1]
      message = "#{message} at #{file}:#{line}"
    end

    unless ENV['SIMPLIB_LOG_DEPRECATIONS'] == 'false'
      Puppet.deprecation_warning(message, key)
    end
  end
end
