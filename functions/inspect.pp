# Prints the passed variable's Ruby type and value for debugging purposes
#
# This uses a ``Notify`` resource to print the information during the client
# run.
#
# @param var_name
#   The actual name of the variable, fully scoped, as a ``String``
#
# @param output_type
#   The format that you wish to use to display the output during the run
#
function simplib::inspect (
  String $var_name,
  Enum['json','yaml'] $output_type = 'json'
) {

  $var_value = inline_template("<%= scope[@var_name].to_${output_type} %>")
  $var_class = inline_template('<%= scope[@var_name].class %>')

  notify { "DEBUG_INSPECT_${var_name}":
    message => "Type => ${var_class}\nContent =>\n${var_value}"
  }
}
