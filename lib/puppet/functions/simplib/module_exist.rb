# Determines if a module exists in the current environment
#
Puppet::Functions.create_function(:'simplib::module_exist') do

  # @param module_name The module name to check
  # @return [Boolean] Whether or not the module exists in the current environment
  dispatch :module_exist do
    required_param 'String[1]', :module_name
  end

  def module_exist(module_name)
    if Puppet::Module.find(module_name, closure_scope.compiler.environment.to_s)
      return true
    else
      return false
    end
  end
end
