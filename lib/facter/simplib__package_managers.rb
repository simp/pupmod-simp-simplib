# All discovered package capabilities
#
Facter.add('simplib__package_managers') do
  confine :kernel do |value|
    value.downcase != 'windows'
  end

  setcode do
    command_info = nil

    default_regexp = Regexp.new('\d+\.\d+\.\d+')
    default_match = lambda { |to_match| %(#{default_regexp.match(to_match)}) }

    # A Hash of package commands to find and associated regex match for the
    # version.
    #
    # Each item should have the arguments to pass to the command and a match
    # lambda that should return a String (empty for no match)
    package_metadata = {
      'rpm' => {
        :args => '--version',
        :match => default_match
      },
      'yum' => {
        :args => '--version',
        :match => default_match
      },
      'dnf' => {
        :args => '--version',
        :match => default_match
      },
      'apt' => {
        :args => '--version',
        :match => default_match
      },
      'dpkg' => {
        :args => '--version',
        :match => default_match
      },
      'flatpak' => {
        :args => '--version',
        :match => default_match
      },
      'snap' => {
        :args => '--version',
        :match => default_match
      }
    }

    package_metadata.each do |pkg_name, pkg_opts|
      pkg_cmd = Facter::Util::Resolution.which(pkg_name)

      next unless pkg_cmd

      version_output = Facter::Core::Execution.execute(
        %(#{pkg_cmd} #{pkg_opts[:args]}),
        :timeout => 2,
        :on_fail => nil
      )

      next unless version_output

      version_info = pkg_opts[:match].call(version_output)

      next if version_info.empty?

      command_info ||= {}
      command_info[pkg_name] = version_info
    end

    command_info
  end
end
