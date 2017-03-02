# vim: set expandtab ts=2 sw=2:
Puppet::Functions.create_function(:'simplib::passgen') do
  dispatch :passgen do
    param          'String', :param
    optional_param 'Hash',    :options
  end
  filename = File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))) + "/puppetx/simp/passgen.rb"
  self.class_eval(File.read(filename), filename)
end
