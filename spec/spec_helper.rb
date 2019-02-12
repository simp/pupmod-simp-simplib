require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'
require 'simp/rspec-puppet-facts'
include Simp::RspecPuppetFacts

require 'pathname'

# RSpec Material
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
module_name = File.basename(File.expand_path(File.join(__FILE__,'../..')))

# Add fixture lib dirs to LOAD_PATH. Work-around for PUP-3336
if Puppet.version < "4.0.0"
  Dir["#{fixture_path}/modules/*/lib"].entries.each do |lib_dir|
    $LOAD_PATH << lib_dir
  end
end


if !ENV.key?( 'TRUSTED_NODE_DATA' )
  warn '== WARNING: TRUSTED_NODE_DATA is unset, using TRUSTED_NODE_DATA=yes'
  ENV['TRUSTED_NODE_DATA']='yes'
end

# This can be used from inside your spec tests to load custom hieradata within
# any context.
#
# Example:
#
# describe 'some::class' do
#   context 'with version 10' do
#     let(:hieradata){ "#{class_name}_v10" }
#     ...
#   end
# end
#
# Then, create a YAML file at spec/fixtures/hieradata/some__class_v10.yaml.
#
# You can also create a YAML file that is named the same as your test
# description with all colons and spaces changed to underscores.
#
# Hiera will use this file as it's base of information stacked on top of
# 'default.yaml' and <module_name>.yaml per the defaults below.
#
# Note: Any colons (:) are replaced with underscores (_) in the class name.
def hiera_config_template(hiera_version=5)
  if hiera_version == 3
    hiera_template_content = <<-EOM
---
:backends:
  - "rspec"
  - "yaml"
:yaml:
  :datadir: "<%= hiera_datadir %>"
:hierarchy:
<% if custom_hieradata -%>
  - "<%= custom_hieradata %>"
<% end -%>
<% if spec_title -%>
  - "<%= spec_title %>"
<% end -%>
  - "%{module_name}"
  - "default"
EOM
  else
    hiera_template_content = <<-EOM
---
version: 5
hierarchy:
  - name: SIMP Compliance Engine
    lookup_key: compliance_markup::enforcement
<% if custom_hieradata -%>
  - name: Custom Test Hieradata
    path: "<%= custom_hieradata %>.yaml"
<% end -%>
<% if spec_title -%>
  - name: <%= spec_title %>
    path: "<%= spec_title %>.yaml"
<% end -%>
  - name: <%= module_name %>
    path: "<%= module_name %>.yaml"
  - name: Common
    path: default.yaml
defaults:
  data_hash: yaml_data
  datadir: "<%= hiera_datadir %>"
EOM
  end

  return hiera_template_content
end

# This can be used from inside your spec tests to set the testable environment.
# You can use this to stub out an ENC.
#
# Example:
#
# context 'in the :foo environment' do
#   let(:environment){:foo}
#   ...
# end
#
def set_environment(environment = :production)
  RSpec.configure { |c| c.default_facts['environment'] = environment.to_s }
end

unless File.directory?(File.join(fixture_path,'hieradata'))
  FileUtils.mkdir_p(File.join(fixture_path,'hieradata'))
end

unless File.directory?(File.join(fixture_path,'modules',module_name))
  FileUtils.mkdir_p(File.join(fixture_path,'modules',module_name))
end

RSpec.configure do |c|
  # If nothing else...
  c.default_facts = {
    :production => {
      #:fqdn           => 'production.rspec.test.localdomain',
      :path           => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      :concat_basedir => '/tmp'
    }
  }

  c.mock_framework = :rspec
  c.mock_with :mocha

  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')

  c.hiera_config = File.join(fixture_path,'hieradata','hiera.yaml')

  # Useless backtrace noise
  backtrace_exclusion_patterns = [
    /spec_helper/,
    /gems/
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end

  c.before(:each) do
    @spec_global_env_temp = Dir.mktmpdir('simpspec')

    if defined?(environment)
      set_environment(environment)
      FileUtils.mkdir_p(File.join(@spec_global_env_temp,environment.to_s))
    end

    # ensure the user running these tests has an accessible environmentpath
    Puppet[:environmentpath] = @spec_global_env_temp
    Puppet[:user] = Etc.getpwuid(Process.uid).name
    Puppet[:group] = Etc.getgrgid(Process.gid).name

    hiera_datadir = File.dirname(c.hiera_config)

    # sanitize hieradata
    if defined?(hieradata)
      custom_hieradata = hieradata.gsub(/(:|\s)/,'_')
    elsif defined?(class_name)
      custom_hieradata = class_name.gsub(/(:|\s)/,'_')
    end

    unless File.exist?(File.join(hiera_datadir, "#{custom_hieradata}.yaml"))
      custom_hieradata = nil
    end

    if self.class.description && !self.class.description.empty?
      spec_title = self.class.description.gsub(/(:|\s)/,'_')

      unless File.exist?(File.join(hiera_datadir, "#{spec_title}.yaml"))
        spec_title = nil
      end
    end

    hiera_version ||= 5
    data = YAML.load(ERB.new(hiera_config_template(hiera_version.to_i), nil, '-').result(binding))

    File.open(c.hiera_config, 'w') do |f|
      f.write data.to_yaml
    end
  end

  c.after(:each) do
    # clean up the mocked environmentpath
    FileUtils.rm_rf(@spec_global_env_temp)
    @spec_global_env_temp = nil
  end
end

Dir.glob("#{RSpec.configuration.module_path}/*").each do |dir|
  begin
    Pathname.new(dir).realpath
  rescue
    fail "ERROR: The module '#{dir}' is not installed. Tests cannot continue."
  end
end

if ENV['PUPPET_DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end
