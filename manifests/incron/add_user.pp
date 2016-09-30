# _Description_
#
# Add the user $name to /etc/incron.allow
#
# _Variables_
# * $name
#   The user to add to /etc/incron.allow
#
define simplib::incron::add_user
{
  include 'simplib::incron'

  simpcat_fragment { "incron+${name}.user":
    content =>  "${name}\n"
  }
}
