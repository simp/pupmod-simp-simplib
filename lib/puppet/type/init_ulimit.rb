Puppet::Type.newtype(:init_ulimit) do
  desc <<-EOT
  Update ulimit settings in init scripts.

  The resource name does have to be unique but is meaningless.

  Valid 'limit_type' names are:
    b|socket_buffer_size
    c|max_core_size
    d|max_data_segment
    e|max_nice
    f|max_file_size
    i|max_pending_signals
    l|max_memory_lock_size
    m|max_resident_set_size
    n|max_open_files (default)
    p|max_queue_size
    r|max_real_time_pri
    s|max_stack_size
    t|max_cpu_time
    u|max_num_procs
    v|max_virt_memory
    x|max_file_locks
    T|max_threads

  All of these are explained in the 'ulimit' section of bash_builtins(1)

  The parameter names are taken from the descriptive field names used in
  limits.conf.

  Example:

  init_ulimit { 'rsyslog':
    ensure     => 'present',
    limit_type => 'both'
    item       => 'max_open_files',
    value      => 'unlimited'
  }

  This is the same as:

  init_ulimit { 'rsyslog':
    item       => 'n',
    value      => 'unlimited'
  }
  EOT

  $init_ulimit_opt_map = {
    'b'                     => 'b',
    'c'                     => 'c',
    'd'                     => 'd',
    'e'                     => 'e',
    'f'                     => 'f',
    'i'                     => 'i',
    'l'                     => 'l',
    'm'                     => 'm',
    'n'                     => 'n',
    'p'                     => 'p',
    'r'                     => 'r',
    's'                     => 's',
    't'                     => 't',
    'u'                     => 'u',
    'v'                     => 'v',
    'x'                     => 'x',
    'T'                     => 'T',
    'socket_buffer_size'    => 'b',
    'max_core_size'         => 'c',
    'max_data_segment'      => 'd',
    'max_nice'              => 'e',
    'max_file_size'         => 'f',
    'max_pending_signals'   => 'i',
    'max_memory_lock_size'  => 'l',
    'max_resident_set_size' => 'm',
    'max_open_files'        => 'n',
    'max_queue_size'        => 'p',
    'max_real_time_pri'     => 'r',
    'max_stack_size'        => 's',
    'max_cpu_time'          => 't',
    'max_num_procs'         => 'u',
    'max_virt_memory'       => 'v',
    'max_file_locks'        => 'x',
    'max_threads'           => 'T'
  }

  ensurable

  def self.title_patterns
    [
      [
        /^(\|?)(.*)$/,
        [
         [:item, lambda{|x| x}],
         [:target, lambda{|x| x}]
        ]
      ]
    ]
  end

  def initialize(*args)
    super(*args)

    if File.dirname(self[:target]) == '/etc/init.d' then
      self.provider = 'sysv'
    end
  end

  newparam(:name) do
    desc 'A unique name for the resource'
  end

  newparam(:target) do
    isnamevar
    desc 'The service that will be modified. If you specify a full path, that will be used instead.'

    munge do |value|
      if value !~ /^\// then
        # Prevent unexpected directory traversing!
        value = value.gsub('/','_') unless value[0].chr == '/'
      end

      value
    end

  end

  newparam(:limit_type) do
    desc 'The limit type: hard|soft|both'
    newvalues(:soft, :hard, :both)

    defaultto 'both'

    munge do |value|
      value.downcase
    end
  end

  newparam(:item) do
    isnamevar
    desc 'The system limit resource to modify'
    defaultto 'max_open_files'

    munge do |value|
      $init_ulimit_opt_map[value.downcase]
    end

    validate do |value|
      if not $init_ulimit_opt_map.keys.include?(value.downcase) then
        raise(Puppet::Error, "'item' must be one of '#{$init_ulimit_opt_map.keys.join(', ')}")
      end
    end
  end

  newproperty(:value) do
    desc 'The value to which to set the new limit.'
    newvalues(:hard, :soft, :unlimited, /^\d+$/)

    munge do |value|
      value = value.downcase.strip

      # Unlimited doesn't work in the case of file descriptors so munge it to the system max.
      resource[:item] == 'n' and value == 'unlimited' and value = '1048576'
      value
    end
  end

  validate do
    unless self[:target]
      raise(Puppet::Error, "You must specify a valid 'target'")
    end

    if self[:ensure] != :absent then
      unless self[:item] and self[:value]
        raise(Puppet::Error, "Both 'item' and 'value' are required parameters")
      end
    end
  end

  def finish
    dep = @catalog.resource("Service[#{File.basename(self[:target])}]")
    res_comp = []
    self[:notify] and res_comp = self[:notify].map{|x| x.to_s}

    if dep then
      if self[:notify] and not self[:notify].empty? and not res_comp.include?(dep.to_s) then
        self[:notify] << dep.retrieve_resource
      else
        self[:notify] = [ dep.to_s ]
      end
    end
    super
  end
end
