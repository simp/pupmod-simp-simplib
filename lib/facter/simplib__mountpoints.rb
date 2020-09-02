#
# This fact provides information about select mountpoints that are of interest
# to other SIMP modules.
#
# The results are organized as a Hash with at least the following information.
# Information from the main `mountpoints` fact is used if found but corrected
# for bind mounts.
#
# Any `uid` and `gid` options will have additional options added into the
# `options_hash` called `_user` and `_group` to differentiate them from internal
# mount options.
#
# NOTE: Any item starting with `_` has been added in as a 'helper'.
#
# All integer values in `mount_options` will be translated to `Integers`.
#
# {
#   '/mountpoint' => {
#     'device'       => '/dev/something',
#     'filesystem'   => 'filesystem type',
#     'options'      => ['mount', 'options', 'gid=100'],
#     'options_hash' => {
#       'mount'   => nil,
#       'options' => nil,
#       'gid'     => '100',
#       '_group'  => 'users'
#     }
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
          # Split on commas that are not in quotes
          'options'    => opts.gsub(/'|"/,'').split(/,(?=(?:(?:[^'"]*(?:'|")){2})*[^'"]*$)/).map(&:strip)
        }
      end
    end

    # Lookup table so we don't constantly lookup found UIDs and GIDs, etc...
    known_translations = {}

    # Check for bind mounts using findmnt since some systems (EL7) do not post the
    # 'bind' keyword into the mount options any longer.
    mount_list.keys.each do |mnt|
      mount_list[mnt]['options'] ||= []

      unless mount_list[mnt]['options'].include?('bind')
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

      # Add an 'options_hash' for easy processing
      mount_list[mnt]['options_hash'] = Hash[
        mount_list[mnt]['options'].map { |opt|
          # Split on options that are not in quotes
          opt.split(/=(?=(?:(?:[^'"]*(?:'|")){2})*[^'"]*$)/).map(&:strip)
        }.map { |opt_arr|
          if opt_arr[1] && opt_arr[1] =~ /\A\d+\Z/
            [opt_arr[0], opt_arr[1].to_i]
          else
            [opt_arr[0], opt_arr[1]]
          end
        }
      ]

      # Helper translation material
      if mount_list[mnt]['options_hash']['uid']
        require 'etc'

        begin
          mount_list[mnt]['options_hash']['_user'] = Etc.getpwuid(mount_list[mnt]['options_hash']['uid'])
        rescue ArgumentError
          # noop
        end
      end

      if mount_list[mnt]['options_hash']['gid']
        begin
          mount_list[mnt]['options_hash']['_group'] = Etc.getgrgid(mount_list[mnt]['options_hash']['gid'])
        rescue ArgumentError
          # noop
        end
      end
    end

    mount_list
  end
end
