# _Description_
#
# Add the user $name to /etc/at.allow
#
# _Variables_
# * $name
#   The user to add to /etc/at.allow
define simplib::at::add_user
{
  include 'simplib::at'

  $l_name = regsubst($name,'/','__')

  concat_fragment { "at+$l_name.user":
    content =>  "$name\n"
  }
}
