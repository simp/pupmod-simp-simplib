#
# This fact provides information about select mountpoints that are of interest
# to other SIMP modules.
#
# The results are organized as a Hash with the following information:
#
# {
#   '/mountpoint' => {
#     :path   => '/whatever',
#     :fstype => 'filesystem type',
#     :opts   => 'mount options',
#     :freq   => 'freq field',
#     :passno => 'passno field'
#   }
# }
#
require 'facter'

Facter.add('simplib__mountpoints') do
  setcode do
    confine :kernel => :Linux
    confine { File.exist?('/proc/mounts') }

    target_dirs = %w(
      /tmp
      /var/tmp
      /dev/shm
      /proc
    )

    # Holder of the multi-call content
    mount_list = {}

    facter_mountpoints = Facter.value('mountpoints') || {}

    # Sometimes Ruby has issues with /proc so fall back to a shell command
    Facter::Util::Resolution.exec('cat /proc/mounts 2> /dev/null').each_line do |line|
      line.strip!

      next if line.empty? || line.match(/^\s+none\s+/)

      dev,path,fs,opts,_junk = line.split(/\s+/)

      next unless target_dirs.include?(path)

      if facter_mountpoints[path]
        mount_list[path] = facter_mountpoints[path]
      else
        # If there are multiple mounts at the same mountpoint, this picks up the very
        # last one, which is what you want.
        mount_list[path] = {
          'device'     => dev,
          'filesystem' => fs,
          'options'    => opts.gsub(/'|"/,'').split(',')
        }
      end
    end

    # Check for bind mounts using findmnt since some systems (EL7) do not post the
    # 'bind' keyword into the mount options any longer.
    mount_list.keys.each do |mnt|
      mount_list[mnt]['options'] ||= []
      next if mount_list[mnt]['options'].include?('bind')

      findmnt_output = Facter::Util::Resolution.exec("findmnt #{mnt}")
      # on RHEL 5 the command "findmnt" doesn't exist, if it doesn't exist
      # then we just want to ignore this since there's nothing to do
      if findmnt_output
        mnt_source = findmnt_output.lines.last.split(/\s+/)[1]

        # We're a bind mount if this happens
        if mnt_source.include?('[')
          bind_source = mnt_source[/\[(.*)\]/,1] # Match contents in brackets, extract first match

          mount_list[mnt]['device'] = bind_source
          mount_list[mnt]['filesystem'] = 'none'
          mount_list[mnt]['options'] << 'bind'
        end
      end
    end

    mount_list
  end
end
