# _Description_
#
# Add the user $name to /etc/cron.allow
#
# _Variables_
# * $name
#   The user to add to /etc/cron.allow
define simplib::cron::add_user
{
  include 'simplib::cron'

  $l_name = regsubst($name,'/','__')

  concat_fragment { "cron+$l_name.user":
    content =>  "$name\n"
  }

  pam::access::manage { "cron_user_$l_name":
    users   => $l_name,
    origins => ['cron', 'crond']
  }
}
