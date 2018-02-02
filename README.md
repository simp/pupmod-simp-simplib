[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-simplib.svg)](https://travis-ci.org/simp/pupmod-simp-simplib)

#### Table of Contents
1. [Overview](#this-is-a-simp-module)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with simplib](#setup)
    * [What simplib affects](#what-simplib-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with simplib](#beginning-with-simplib)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Facts](#facts)
    * [Functions](#functions)
    * [Puppet Extensions](#puppet-extensions)
    * [Puppet 3 Functions](#puppet-3-functions)
    * [Types](#types)
    * [Data Types](#data-types)
6. [Development - Guide for contributing to the module](#development)

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

## Module Description

*simp/simplib* provides a standard library of resources for SIMP modules. It adds the following
resources to Puppet:
  * Stages
  * Data Types
  * Custom Types and Providers
  * Facts
  * Functions
  * Puppet Extensions
  * Puppet 3 Functions (deprecated functions that will be removed in the near future)

## Setup

### What simplib affects

simplib contains functions, facts, and small utility classes.

### Setup Requirements

Agents will need to enable `pluginsync`.

## Usage


Please see [reference](#reference) for usage.

Full documentation can be found in the [module docs](https://simp.github.io/pupmod-simp-simplib)

## Reference

A list of things provided by simplib is below.

Please reference the `doc/` directory in the top level of the repo or the code
itself for more detailed documentation.

### Stages

 simplib::stages are added to ensure that anyone using the stdlib stages was not
 tripped up by any simp modules that may enable, or disable, various system,
 components; particularly ones that require a reboot.

 Added Stages:

   * ``simp_prep`` -> Comes before stdlib's ``setup``
   * ``simp_finalize`` -> Comes after stdlib's ``deploy``

### Facts

  * **acpid_enabled**        -  Return true if ACPI is available on the system
  * **boot_dir_uuid**        -  Return the UUID of the partition holding the
   boot directory
  * **cmdline**              -  Returns the contents of `/proc/cmdline` as a
   hash
  * **cpuinfo**              -  Returns the contents of `/proc/cpuinfo` as a
   hash
  * **defaultgateway**       -  Return the default gateway of the system
  * **defaultgatewayiface**  -  Return the default gw interface of the system
  * **fips_ciphers**         -  Returns a list of available OpenSSL ciphers
  * **fips_enabled**         -  Determine whether or not FIPS is enabled on
   this system
  * **fullrun**              -  Determine whether or not to do an intensive run
  * **gdm_version**          -  Return the version of GDM that is installed
  * **grub_version**         -  Return the grub version installed on the system
  * **init_systems**         -  Return a list of all init systems present on
   the system
  * **ipa**                  -  Return a hash containing the IPA domain and
   server to which a host is connected
  * **ipv6_enabled**         -  Return true if IPv6 is enabled and false if not
  * **login_defs**           -  Return the contents of `/etc/login.defs` as a
   hash with downcased keys
  * **prelink**              -  Returns a hash containing prelink status
  * **reboot_required**      -  Returns a hash of 'name' => 'reason' entries
  * **root_dir_uuid**        -  Return the UUID of the partition holding the
   `/` directory
  * **runlevel**             -  Return the current system runlevel
  * **shmall**               -  Return the value of shmall from sysctl
  * **simplib_sysctl**       -  Return hash of sysctl values that are relevant
   to SIMP
  * **simp_puppet_settings** -  Returns a hash of all Puppet settings on a node
  * **tmp_mounts**           -  This fact provides information about `/tmp`,
  `/var/tmp`, and `/dev/shm` should they be present on the system
  * **uid_min**              -  Return the minimum uid allowed

### Functions


- [assert\_metadata](#simplibassert_metadata)
- [deprecation](#simplibdeprecation)
- [filtered](#simplibfiltered)
- [gen\_random\_password](#simplibgen_random_password)
- [ip\_to\_cron](#simplibip_to_cron)
- [ipaddresses](#simplibipaddresses)
- [join\_mount\_opts](#simplibjoin_mount_opts)
- [knockout](#simplibknockout)
- [ldap::domain\_to\_dn](#simplibldapdomain_to_dn)
- [lookup](#simpliblookup)
- [nets2cidr](#simplibnets2cidr)
- [nets2ddq](#simplibnets2ddq)
- [parse\_hosts](#simplibparse_hosts)
- [passgen](#simplibpassgen)
- [rand\_cron](#simplibrand_cron)
- [strip\_ports](#simplibstrip_ports)
- [to\_integer](#simplibto_integer)
- [to\_string](#simplibto_string)
- [validate\_array\_member](#simplibvalidate_array_member)
- [validate\_between](#simplibvalidate_between)
- [validate\_bool](#simplibvalidate_bool)
- [validate\_deep\_hash](#simplibvalidate_deep_hash)
- [validate\_net\_list](#simplibvalidate_net_list)
- [validate\_port](#simplibvalidate_port)
- [validate\_re\_array](#simplibvalidate_re_array)
- [validate\_sysctl\_value](#simplibvalidate_sysctl_value)
- [validate\_uri\_list](#simplibvalidate_uri_list)


#### simplib::assert\_metadata

Fails a puppet catalog compile if the client system is not compatible
with the module's `meta_data.json`

*Arguments:*
* ``module_name``  module name
* ``options``       (Optional) Behavior modifiers for the function)

Options takes the form:
  enable => If set to `false` disable all validation
  os
    validate => Whether or not to validate the OS settings
    options
      release_match => Enum['none','full','major']
        none  -> No match on minor release (default)
        full  -> Full release must match
        major -> Only the major release must match

*Example*:
```puppet
    simplib::assert_metadata('mymodule')
```
*Returns*: `nil`

#### **simplib::deprecation**

Function to print deprecation warnings, logging a warning once
for a given key.

Messages can be enabled if the SIMPLIB_LOG_DEPRECATIONS
environment variable is set to 'true'

*Arguments*:
* ``key``      Uniqueness key, which is used to dedupe of messages)
* ``message``  Message to be printed, file and line info
           will be appended if available.)

*Examples*:

```puppet
  simplib::deprecation('gnome::dconf::add','gnome::dconf::add is a shim for gnome::config::dconf and will be removed in a future version')
  # Writes message to log if SIMPLIB_LOG_DEPRECATIONS is true.
```
*Returns*: `nil`

#### **simplib::filtered**
Hiera v5 backend that takes a list of allowed hiera key names, and only
returns results from the underlying backend function that match those keys.

This allows hiera data to be delegated to end users in a multi-tenant
environment without allowing them the ability to override every hiera data
point (and potentially break systems)

#### **simplib::gen_random_password**

Generates a random password string.

*Arguments*:
* ``length``           (Optional) Integer - length of the string to return
* ``complexity``       (Optional) Integer -Specifies the types of characters to be used in the password)
                     `0` => Use only Alphanumeric characters (safest)
                     `1` => Use Alphanumeric characters and reasonably safe symbols
                     `2` => Use any printable ASCII characters
* ``complex_only``    (Optional) Boolean - Use only the characters explicitly added by the complexity rules)
* ``timeout_seconds`` (Optional) Integer or Float - Maximum time allotted to generate
                     the password; a value of 0 disables the timeout

*Returns*: `String` Generated password

Raises a RuntimeError if password cannot be created within allotted time

#### **simplib::ipaddresses**

Return an array of all IP addresses known to be associated with the client. If
an argument is passed, and is not false, then only return non-local addresses.

*Arguments*:
* ``only_remote`` (Optional) Whether to exclude local addresses
     from the return value.

*Returns*: `Array`

#### **simplib::ip_to_cron**

Transforms an IP address to one or more interval values for `cron`.
This can be used to avoid starting a certain cron job at the same
time on all servers.ovides a "random" value to cron based on the passed integer value.

*Arguments*:
* ``occurs``     (Optional) The occurrence within an interval, i.e.,
                the number of values to be generated for the interval.
* ``max_value`` (Optional) The maximum value for the interval.  The values
                generated will be in the inclusive range [0, max_value].
* ``algorithm``  (Optional) When 'ip_mod', the modulus of the IP number is used as the basis
                for the returned values.  This algorithm works well to create
                cron job intervals for multiple hosts, when the number of hosts
                exceeds the `max_value` and the hosts have largely, linearly-
                assigned IP addresses.
                When 'sha256', a random number generated using the IP address
                string is the basis for the returned values.  This algorithm
                works well to create cron job intervals for multiple hosts,
                when the number of hosts is less than the `max_value` or the
                hosts do not have linearly-assigned IP addresses.
* ``ip``         (Optional) The IP address to use as the basis for the generated values.
                 When `nil`, the 'ipaddress' fact (IPv4) is used.

*Examples*:
  Generate one value for the `minute` cron interval

```ruby
    simplib::ip_to_cron()
```
  Generate 2 values for the `hour` cron interval, using the
  sha256' algorithm and a provided IP address
```ruby
     simplib::ip_to_cron(2,23,'sha256','10.0.23.45')
```
*Returns*: `Array[Integer]` Array of integers suitable for use in the
  ``minute`` or ``hour`` cron field.


#### **simplib::join_mount_opts**

Merge two sets of 'mount' options in a reasonable fashion. The second set will
always override the first.

*Arguments*:
* ``system_mount_opts`` System mount options
* ``new_mount_opts``    New mount options, which will override
                        `system_opts` when there are conflicts

*Returns*: `String`

#### **simplib::knockout**

Uses the knockout prefix of '--' to remove elements from an array.

*Arguments*:
* ``array``  The array to work on

*Examples*:
```puppet
  array = [
    'ssh',
    'sudo',
    '--ssh',
  ]
  result = simplib::knockout(array)
# returns: result => [ 'sudo' ]
```
*Returns*: `Array`


#### **simplib::ldap::domain_to_dn**

Takes a DNS domain name and converts it to an LDAP domain name.

Arguments:
* ``domain``               (Optional) The dns domain name, defaults to fact domain.
* ``downcase_attributes`` (Optional) Whether or not to downcase the LDAP attributes, false

*Returns*: `String`

#### **simplib::lookup**

A function for falling back to global scope variable lookups when the
Puppet 4 ``lookup()`` function cannot find a value.

While ``lookup()`` will stop at the back-end data sources, ``lookup()`` will
check the global scope first to see if the variable has been defined.

This means that you can pre-declare a class and/or use an ENC and look up the
variable whether it is declared this way or via Hiera or some other back-end.

*Arguments*:
* ``param``     The parameter you wish to look up.
* ``options``   (Optional)Hash of options for regular ``lookup()``
            This **must** follow the syntax rules for the
            Puppet ``lookup( [<NAME>], <OPTIONS HASH> )`` version of ``lookup()``
            No other formats are supported!
*Examples*:
```puppet
  # No defaults
  simplib::lookup('foo::bar::baz')
  # With a default
  simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana' })
  # With a typed default
  simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana', 'value_type' => String })
```

*Returns*: `Any` The value that is found in the system for the passed

#### **simplib::nets2cidr**

Take an input list of networks and returns an equivalent `Array` in
CIDR notation.
Hostnames are passed through untouched.

*Arguments*:
* ``networks_list``  List of 1 or more networks separated by spaces,
                 commas, or semicolons

*Returns* `Array[String]` Array of networks in CIDR notation

#### **simplib::nets2ddq**

Tranforms a list of networks into an equivalent array in
dotted quad notation.

CIDR networks are converted to dotted quad notation networks.
IP addresses and hostnames are left untouched.

*Arguments*:
* ``networks``  The networks to convert

*Examples*:
```puppet
  # Convert Array input
  $foo = [ '10.0.1.0/24',
           '10.0.2.0/255.255.255.0',
           '10.0.3.25',
           'myhost' ]
  $bar = simplib::nets2ddq($foo)
  #
  # returns  $bar = [ '10.0.1.0/255.255.255.0',
  #                   '10.0.2.0/255.255.255.0',
  #                   '10.0.3.25',
```

*Returns*: `Array[String]` Converted input
           raise RuntimeError if any input item is not a valid network
           or hostname

#### **simplib::parse_hosts**

Convert an `Array` of items that may contain port numbers or protocols
into a structured `Hash` of host information.

Works with Hostnames as well as IPv4 and IPv6 addresses.

**NOTE:** IPv6 addresses will be returned normalized with square brackets
around them for clarity.

*Arguments*:
* ``hosts``   Array of host entries, where each entry may contain
        a protocol or both a protocol and port

*Examples*:
```puppet
  # Input with multiple host formats:
  simplib::parse_hosts([
    '1.2.3.4',
    'http://1.2.3.4',
    'https://1.2.3.4:443'
  ])
  #   Returns:
  #   {
  #     '1.2.3.4' => {
  #       :ports     => ['443'],
  #       :protocols => {
  #         'http'  => [],
  #         'https' => ['443']
  #       }
  #     }
  #   }
```
*Returns*: `Hash` Structured Hash of the host information

#### **simplib::passgen**

Generates a random password string for a passed identifier. Returns
the password or a hash of the password depending on arguments.  It also
stores the password on the puppetserver using
Puppet\[:environmentpath\]/\$environment/simp\_autofiles/gen\_passwd/ as the
destination directory.

The minimum length password that this function will return is 6
characters.

If no, or an invalid, second argument is provided then it will return the
    currently stored string.

*Arguments*:
* ``identifier``      Unique `String` to identify the password usage.
* ``modifier_hash``  (Optional) may contain any of the following options:
                    - 'last' => false(*) or true
                      * Return the last generated password
                    - 'length' => Integer
                      * Length of the new password
                    - 'hash' => false(*), true, md5, sha256 (true), sha512
                      * Return a hash of the password instead of the password itself.
                    - 'complexity' => 0(*), 1, 2
                      * 0 => Use only Alphanumeric characters in your password (safest) 1 =>
                      * Add reasonably safe symbols 2 => Printable ASCII

*Examples*:
```puppet
    #run pasgen for the firstime
    password = simplib::passgen('myfavpasswd',{'length'=> 34})
    #returns password = string of length 34 plain text.

    # Generate the password and return the hash
    password = simplib::passgen('yourfavpasswd',{ hash => 'sha256' })
    # returns sha256 hash of generated password and salt.

    # To retrieve the above password (assuming the above command
    #  was run previously in the catalog or on an earlier catalog run:
    password = simplib::passgen('yourfavpasswd')
    # returns the 32 character password generated by the first call
```

*Returns*: `String` Password specified

#### **simplib::rand_cron**

Transforms an input string to one or more interval values for `cron`.
This can be used to avoid starting a certain cron job at the same
time on all servers.

*Arguments*:
* ``modifier``    The input string to use as the basis for the generated values
* ``algorithm``   Randomization algorithm to apply to transform the input string.
* ``occurs``      (Optional) The occurrence within an interval
* ``max_value``  (Optional) The maximum value for the interval.

*Examples*:
```puppet
   # Generate one value for the `minute` cron interval using using sha256
   simplib::rand_cron('myhost.test.local','sha256')

  # Generate 2 values for the `hour` cron interval, using the
  # 'ip_mod' algorithm
  simplib::rand_cron('10.0.6.78', 'ip_mod', 2, 23)
```

*Returns*: `Array[Integer]` Array of integers suitable for use
            in the ``minute`` or ``hour`` cron field

#### **simplib::strip_ports**
Extract list of unique hostnames and/or IP addresses from an `Array`
of hosts, each of which may may contain protocols and/or port numbers

*Arguments*:
* hosts   Array of hosts which may contain protocols and port numbers

*Examples*:
```puppet
$foo = ['https://mysite.net:8443',
        'http://yoursite.net:8081',
        'https://theirsite.com']

$bar = strip_ports($foo)

# results  $bar = ['https://mysite.net','http://yoursite.net','theirsite.com']
```

*Returns*: `Array` Non-port portion of hostnames

#### **simplib::to_integer**
Converts the argument into an Integer.
Only works if the passed argument responds to the 'to\_i' Ruby method.

*Returns*: `integer`

#### **simplib::to_string**
Converts the argument into a String.
Only works if the passed argument responds to the 'to\_s' Ruby method.

*Returns*: `string`

#### **simplib::validate_array_member**
Validate that the first string (or array) passed is a member of the second
array passed. An optional third argument of i can be passed, which ignores
the case of the objects inside the array.

*Arguments*:
* ``input``    The element to find in the target array.
* ``target``   The array to search.
* ``modifier`` (Optional) If 'i' ignores case.

*Examples*:
```ruby
validate_array_member('foo',['foo','bar'])     # => true
validate_array_member('foo',['FOO','BAR'])     # => false

#Optional 'i' as third object, ignoring case of FOO and BAR#

validate_array_member('foo',['FOO','BAR'],'i') # => true
```

*Returns*: `Boolean` Whether or not the argument is an element of the
            array.

#### **simplib::validate_between**
Validate that the first value is between the second and third values
numerically, inclusively. Fail catalog compile if not.

Deprecated:  You should be able to use type declarions instead of this.

*Arguments*:
* ``value``       Value to validate
* ``min_value``   Minimum value that is valid
* ``max_value``   Maximum value that is valid

*Returns*: `nil`

#### **simplib::validate_bool**
Validate that all passed values are either true or false. Abort catalog
compilation if any value fails this check.

Modified from the stdlib validate\_bool to handle the strings 'true' and
'false'.

The following values will pass:

*Arguments*:
* ``values_to_validate``   The value to validate.

*Examples*:
```ruby
$iamtrue = true

validate_bool(true)
validate_bool("false")
validate_bool("true")
validate_bool(true, 'true', false, $iamtrue)
```

The following values will fail, causing compilation to abort:

```ruby
$some_array = [ true ]

validate_bool($some_array)
```

*Returns*: `nil` Fails catalog compilation if it is not a Boolean'

#### **simplib::validate_deep_hash**
Perform a deep validation on two passed `Hashes`.

The first hash is the one to validate against, and the second is the one being
validated.

All keys must be defined in the reference `Hash` that is being
validated against.

Unknown keys in the `Hash` being compared will cause a failure in
validation

All values in the final leaves of the 'reference 'Hash' must
be a String, Boolean, or nil.

All values in the final leaves of the `Hash` being compared must
support a to\_s() method.

*Arguments*:
* ``reference``   Reference Hash
* ``to_check``   Hash to validate.

*Examples*:
```puppet
  # Passing Examples
   reference = {
     'foo' => {
       'bar' => {
         #NOTE: Use quotes for regular expressions instead of '/'
         'baz' => '^\d+$',
         'abc' => '^\w+$',
         'def' => nil
       },
       'baz' => {
         'qrs' => false
         'xyz' => '^true|false$'
       }
     }
   }

   to_check = {
     'foo' => {
       'bar' => {
         'baz' => ['123', 45]
         'abc' => [ 'these', 'are', 'words' ],
         'def' => 'Anything will work here!'
       },
       'baz' => {
         'qrs' => false
         'xyz' => true
       }
     }
   }
  simplib::validate_deep_hash(reference, to_check)

  # Failing Examples
  reference => { 'foo' => '^\d+$' }
  to_check  => { 'foo' => 'abc' }

  simplib::validate_deep_hash(reference, to_check)
```
*Returns*: `nil` Fails catalog compilation they do not match.

#### **simplib::validate_port**
Validates whether or not the passed argument is a valid port (i.e.  between
1 - 65535).  It will work on strings ot integers.

*Arguments*:
* ``port_args``  A port or array of ports.

*Examples*:
```puppet
# Examples that pass
$port = '10541'
$ports = [5555, 7777, 1, 65535]

simplib::validate_port($port)
simplib::validate_port($ports)
simplib::validate_port($port, $ports)

# The following values will not pass:

simplib::validate_port('0')
simplib::validate_port(65536)
```

*Returns*: `nil` Catalog compilation will fail if it does not pass.

#### **simplib::validate_net_list**
Validate that a passed list (`Array` or single `String`) of networks
is filled with valid IP addresses, network addresses (CIDR notation),
or hostnames. Hostnames are checked per RFC 1123. Ports appended with
a colon `:` are allowed for hostnames and individual IP addresses.

*Arguments*:
* ``net``         Single network to be validated.
* ``str_match``  (Optional) A regex of `String` that should be ignored
              from the list. Omit the beginning and ending `/` delimiter.
*Examples*:
```puppet
#  Passing

   $trusted_nets = '10.10.10.0/24'
   simplib::validate_net_list($trusted_nets)

   $trusted_nets = '1.2.3.5:400'
   simplib::validate_net_list($trusted_nets)

   $trusted_nets = 'ALL'
   simplib::validate_net_list($trusted_nets,'^(%any|ALL)$')

# Failing

   $trusted_nets = '10.10.10.0/24,1.2.3.4'
   simplib::validate_net_list($trusted_nets)

   $trusted_nets = 'bad stuff'
   simplib::validate_net_list($trusted_nets)
```

*Returns*: `nil` Catalog compilation will fail if it does not pass.

#### **simplib::validate_re_array**
Perform simple validation of a `String`, or `Array` of `Strings`,
against one or more regular expressions.
Derived from the Puppet Labs stdlib validate\_re.

*Arguments*:
* ``input``   String to be validated
* ``regex``   Stringified regex expression (regex without the `//`
   delimiters)
* ``err_msg``  (Optional) error message to emit upon failure

*Examples*:
```puppet
  #  Passing
  simplib::validate_re_array('one', '^one$')
  #
  #  Failing
  simplib::validate_re_array('one', '^two')
  #
  # Custom Error Message
  simplib::validate_re_array($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')
  #
```

*Returns*: `nil` Catalog compilation will fail if it does not pass.

#### **simplib::validate_sysctl_value****

Validate that the passed value is correct for the passed sysctl key.

If a key is not know, simply returns that the value is valid.

*Arguments*:
* ``key``    sysctl setting whose value is to be validated
* ``value``  Value to be validated

*Returns*: `nil` Catalog compilation will fail if it does not pass.

#### **simplib::validate_uri_list**
Validate that a passed list (`Array` or single `String`) of URIs is
valid according to Ruby's URI parser.
Caution:  No scheme (protocol type) validation is done the scheme_list
parameter is not set.

*Arguments*:
* ``uri``          URI to be validated.
* ``scheme_list`` (Optional) List of schemes (protocol types) allowed for the URI.

*Examples*:
```puppet
# The following values will pass:
$uris = [http://foo.bar.baz:1234','ldap://my.ldap.server']
simplib::validate_uri_list($uris)

$uris = ['ldap://my.ldap.server','ldaps://my.ldap.server']
simplib::validate_uri_list($uris,['ldap','ldaps'])
```

*Returns*: `nil` Catalog compilation will fail if it does not pass.

### Puppet Extensions
- [hostname_only?](#hostname_only)
- [hostname?](#hostname)
- [split_port](#split_port)

#### **hostname_only?**
Determine whether or not the passed value is a valid hostname.
Returns false if is not comprised of ASCII letters (upper or lower case),
digits, hypens (except at the beginning and end), and dots (except at
beginning and end)
NOTE:  This returns true for an IPv4 address, as it conforms to RFC 1123.

*Examples*:
```ruby
  # Returns True
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com')

  # Returns false
  PuppetX::SIMP::Simplib.hostname?('-hostname.me.com')

  # Returns false
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com:5454')

```
*Returns*: `Boolean`

#### **hostname?**
Determine whether or not the passed value is a valid hostname optionally
postpended with ':<number>' or '/<number>'.
Returns false if is not comprised of ASCII letters (upper or lower case),
digits, hypens (except at the beginning and end), and dots (except at
beginning and end), optional pluss ':<number>' or '/<number>'
NOTE:  This returns true for an IPv4 address, as it conforms to RFC 1123.
*Examples*:
```ruby
  # Returns True
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com')

  # Returns false
  PuppetX::SIMP::Simplib.hostname?('-hostname.me.com')

  # Returns true
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com:5454')
```

*Returns*: `Boolean`

#### **split_port**
Return a host/port pair

*Examples*:
```ruby
  PuppetX::SIMP::Simplib.split_port['myhost.name:5656']
  #returns ['myhost.name','5656']

  PuppetX::SIMP::Simplib.split_port['192.165.3.9/24']
  #returns [nil, nil]

  PuppetX::SIMP::Simplib.split_port['192.165.3.9']
  #returns ['192.165.3.9',nil]
```

*Returns*: `Array[ hostname, port]`

### Deprecated Puppet 3 Functions

These functions have all been deprecated.  This is here for information purposes only.
Use functions from the `Functions` section in new code.
Many of them have been replaced by standard puppet functions, data type functionality
in puppet 4 and later versions.

If there is a corresponding simplib function for versions of puppet later than
version 3, it is noted in the comments.

- [array\_include](#array_include)
- [array\_size](#array_size)
- [array\_union](#array_union)
- [bracketize](#bracketize)
- [deep\_merge](#deep_merge)
- [filtered](#filtered)
- [generate\_reboot\_msg](#generate_reboot_msg)
- [get\_ports](#get_ports)
- [h2n](#h2n)
- [host\_is\_me](#host_is_me)
- [inspect](#inspect)
- [ip\_is\_me](#ip_is_me)
- [ip\_to\_cron](#ip_to_cron)
- [ipaddresses](#ipaddresses)
- [join\_mount\_opts](#join_mount_opts)
- [localuser](#localuser)
- [mapval](#mapval)
- [nets2cidr](#nets2cidr)
- [nets2ddq](#nets2ddq)
- [parse\_hosts](#parse_hosts)
- [passgen](#passgen)
- [rand\_cron](#rand_cron)
- [simp\_version](#simp_version)
- [slice\_array](#slice_array)
- [strip\_ports](#strip_ports)
- [to\_integer](#to_integer)
- [to\_string](#to_string)
- [validate\_array\_member](#validate_array_member)
- [validate\_array\_of\_hashes](#validate_array_of_hashes)
- [validate\_between](#validate_between)
- [validate\_bool\_simp](#validate_bool_simp)
- [validate\_deep\_hash](#validate_deep_hash)
- [validate\_float](#validate_float)
- [validate\_integer](#validate_integer)
- [validate\_macaddress](#validate_macaddress)
- [validate\_net\_list](#validate_net_list)
- [validate\_port](#validate_port)
- [validate\_re\_array](#validate_re_array)
- [validate\_sysctl\_value](#validate_sysctl_value)
- [validate\_umask](#validate_umask)
- [validate\_uri\_list](#validate_uri_list)

#### **array\_include**

This function has been deprecated

Determine if the first passed array contains the contents of another array or
string.

Example:

```ruby
$arr_x = [ 'foo', 'bar' ]
$arr_y = [ 'foo', 'baz', 'bar' ]

if array_include($arr_x, $arr_y) {
  notice('this will be printed')
}
if array_include($arr_x, 'bar') {
  notice('this will be printed')
}
if array_include($arr_x, 'baz') {
  notice('this will not be printed')
}
```

Returns: `boolean`

#### **array\_size**

This function has been deprecated

Returns the number of elements in an array. If a string is passed, simply
returns '1'.

This is in contrast to the Puppet Labs stdlib 'size' function which returns
the size of an array or the length of a string when called.

Returns: `integer`

#### **array\_union**

This function has been deprecated

Return the union of two arrays.

Example:

```ruby
$arr_x = ['1','2']
$arr_y = ['2','3','4']

$res = array_union($arr_x, $arr_y)

$res contains: ['1','2','3','4']
```

Returns: `array`

#### **bracketize**

This function has been deprecated

Add brackets to IP addresses and arrays of IP addresses based on the
rules for bracketing IPv6 addresses. Ignore anything that doesn't
look like an IPv6 address.

Returns: `string` or `array`

#### **deep\_merge**

This function has been deprecated

Perform a deep merge on two passed hashes.

This code is shamelessly stolen from the guts of
ActiveSupport::CoreExtensions::Hash::DeepMerge and munged together with the
Puppet Labs stdlib 'merge' function.

Returns: `hash`

#### **filtered**

This function has been deprecated
It has been replaced by simplib::filtered

##### data\_hash variant

Hiera v5 backend that takes a list of allowed hiera key names, and only returns
results from the underlying backend function that match those keys.

This allows hiera data to be delegated to end users in a multi-tenant environment
without allowing them the ability to override every hiera data point (and potentially break systems)

Usage:
```yaml
---
version: 5 # Specific version of hiera we are using, required for v4 and v5
defaults:  # Used for any hierarchy level that omits these keys.
  datadir: "data"         # This path is relative to hiera.yaml's directory.
  data_hash: "yaml_data"  # Use the built-in YAML backend.
hierarchy: # Each hierarchy consists of multiple levels
  - name: "OSFamily"
    path: "osfamily/%{facts.osfamily}.yaml"
  - name: "datamodules"
    data_hash: simplib::filtered
    datadir: "delegated-data"
    paths:
            - "%{facts.sitename}/osfamily/%{facts.osfamily}.yaml"
            - "%{facts.sitename}/os/%{facts.operatingsystem}.yaml"
            - "%{facts.sitename}/host/%{facts.fqdn}.yaml"
            - "%{facts.sitename}/common.yaml"
    options:
       function: yaml_data
       filter:
         - profiles::ntp::servers
         - profiles::.*
  - name: "Common"
    path: "common.yaml"
```

Returns: `hash`

#### **generate\_reboot\_msg**

This function has been deprecated

Generate a reboot message from a passed hash.

Requires a hash of the following form:

```ruby
{
  'id'  => 'reason',
  'id2' => 'reason2',
  ...
}
```

Will return a message such as:

```ruby
A system reboot is required due to:
  id => reason
  id2 => reason2
```

Returns: `hash`

#### **get\_ports**

This function has been deprecated

Take an array of items that may contain port numbers and appropriately return
the port portion. Works with hostnames, IPv4, and IPv6.

```
$foo = ['https://mysite.net:8443','http://yoursite.net:8081']

$bar = strip_ports($foo)

$bar contains: ['8443','8081']
```

Returns: `array`

#### **h2n**

This function has been deprecated

Return an IP address for the passed hostname.

Returns: `string`

#### **host\_is\_me**

This function has been deprecated.

Detect if a local system identifier Hostname/IP address is contained in the
passed whitespace delimited list. Whitespace and comma delimiters and passed
arrays are accepted. 127.0.0.1 and ::1 are never matched, use 'localhost' or
'localhost6' for that if necessary.

Returns: `boolean`

#### **inspect**

This function has been deprecated.
It has been replaced by simplib::inspect.
Note: simplib::inspect is a puppet code function.

Prints out Puppet warning messages that display the passed variable.

This is mainly meant for debugging purposes.

Returns: `string`

#### **ipaddresses**

This function has been deprecated
It has been replaced by simplib::ipaddresses

Return an array of all IP addresses known to be associated with the client. If
an argument is passed, and is not false, then only return non-local addresses.

Returns: `array`

#### **ip\_is\_me**

This function has been deprecated

Detect if an IP address is contained in the passed whitespace delimited list.

Returns: `boolean`

#### **ip\_to_cron**

This function has been deprecated
It has been replaced by simplib::ip\_to\_cron

Provides a "random" value to cron based on the passed integer value.
Used to avoid starting a certain cron job at the same time on all
servers.  If used with no parameters, it will return a single value between
0-59. first argument is the occurrence within a timeframe, for example if you
want it to run 2 times per hour the second argument is the timeframe, by
default its 60 minutes, but it could also be 24 hours etc

Pulled from: http://projects.puppetlabs.com/projects/puppet/wiki/Cron_Patterns/8/diff
Author: ohadlevy@gmail.com
License: None

Example:

```ruby
ip_to_cron()     - returns one value between 0..59
ip_to_cron(2)    - returns an array of two values between 0..59
ip_to_cron(2,24) - returns an array of two values between 0..23
```

Returns: `integer` or `array`

#### **join_mount_opts**

This function has been deprecated
It has been replaced by simplib::join\_mount\_opts

Merge two sets of 'mount' options in a reasonable fashion. The second set will
always override the first.

Returns: `string`

#### **localuser**

This function has been deprecated

Pull a pre-set password from a password list and return an array of user
details associated with the passed hostname.

If the password starts with the string '\$1\$' and the length is 34
characters, then it will be assumed to be an MD5 hash to be directly applied
to the system.

If the password is in plain text form, then it will be hashed and stored back
into the source file for future use. The plain text version will be commented
out in the file.

Arguments:
* filename (path to the file containing the local users)
* hostname (host that you are trying to match against)

Returns: `array`

#### **mapval**

This function has been deprecated

Pull a mapped value from a text file. Must provide a Ruby regex!.

Returns: `string`

#### **nets2cidr**


This function has been deprecated
It has been replaced by simplib::nets2cidr

Convert an array of networks into CIDR notation

Returns: `array`

#### **nets2ddq**

This function has been deprecated
It has been replaced by simplib::nets2ddq

Convert an array of networks into dotted quad notation

Returns: `array`

#### **parse\_hosts**

This function has been deprecated
It has been replaced by simplib::parse\_hosts

Take an array of items that may contain port numbers or protocols and return
the host information, ports, and protocols. Works with hostnames, IPv4, and
IPv6.

Example:

```ruby
parse_hosts([ '1.2.3.4', '<http://1.2.3.4>', '<https://1.2.3.4:443>' ])

Returns: '1.2.3.4' => {
           ports => ['443'],
           protocols => {
             'http' => [],
             'https' => ['443']
           }
         }
```
-----------------

> **NOTE**
>
> IPv6 addresses will be returned normalized with square brackets

-----------------

Returns: `hash`

#### **passgen**

This function has been deprecated
It has been replaced by simplib::passgen

Generates a random password string for a passed identifier. Uses
Puppet\[:environmentpath\]/\$environment/simp\_autofiles/gen\_passwd/ as the
destination directory.

```
The minimum length password that this function will return is 6
characters.

    Arguments: identifier, <modifier hash>; in that order.

    <modifier hash> may contain any of the following options:
      - 'last' => false(*) or true
        * Return the last generated password
      - 'length' => Integer
        * Length of the new password
      - 'hash' => false(*), true, md5, sha256 (true), sha512
        * Return a hash of the password instead of the password itself.
      - 'complexity' => 0(*), 1, 2
        * 0 => Use only Alphanumeric characters in your password (safest) 1 =>
        * Add reasonably safe symbols 2 => Printable ASCII

    If no, or an invalid, second argument is provided then it will return the
    currently stored string.
```

Returns: `string`

#### **rand\_cron**

This function has been deprecated
It has been replaced by simplib::rand\_cron

Provides a "random" value to cron based on the passed integer value.
Used to avoid starting a certain cron job at the same time on all
servers.  If used with no parameters, it will return a single value between
0-59 first argument is the occurrence within a timeframe, for example if you
want it to run 2 times per hour the second argument is the timeframe, by
default its 60 minutes, but it could also be 24 hours etc

Based on: http://projects.puppetlabs.com/projects/puppet/wiki/Cron_Patterns/8/diff
Author: ohadlevy@gmail.com
License: None Posted

Example:
```ruby
int_to_cron('100')     - returns one value between 0..59 based on the value 100
int_to_cron(100,2)    - returns an array of two values between 0..59 based on the value 100
int_to_cron(100,2,24) - returns an array of two values between 0..23 based on the value 100
```

Returns: `integer` or `array`

#### **simp\_version**

This function has been deprecated

Return the version of SIMP that this server is running.

Returns: `string`

#### **slice\_array**

This function has been deprecated

Split an array into an array of arrays that contain groupings of 'max_length'
size. This is similar to 'each_slice' in newer versions of Ruby.

```ruby
  * Options *

  to_slice => The array to slice. This will be flattened if necessary.

  max_length => The maximum length of each slice.

  split_char => An optional character upon which to count sub-elements
  as multiples. Only one per subelement is supported.
```

Returns: `array of arrays`

#### **strip\_ports**

This function has been deprecated
It has been replaced by simplib::strip\_ports

Take an array of items that may contain port numbers and appropriately return
the non-port portion. Works with hostnames, IPv4, and IPv6.

```
$foo = ['https://mysite.net:8443',
        'http://yoursite.net:8081',
        'https://theirsite.com']

$bar = strip_ports($foo)

$bar contains: ['https://mysite.net','http://yoursite.net','theirsite.com']
```

Returns: `array`

#### **to\_integer**

This function has been deprecated
It has been replaced by simplib::to\_integer

Converts the argument into an Integer.

Only works if the passed argument responds to the 'to\_i' Ruby method.

Returns: `integer`

#### **to\_string**

This function has been deprecated
It has been replaced by simplib::to\_string

Converts the argument into a String.

Only works if the passed argument responds to the 'to\_s' Ruby method.

Returns: `string`

#### **validate\_array\_of\_hashes**_

This function has been deprecated

Validate that the passed argument is either an empty array or an array that
only contains hashes.

Examples:

```ruby
validate_array_of_hashes([{'foo' => 'bar'}]) # => OK
validate_array_of_hashes([])                 # => OK
validate_array_of_hashes(['FOO','BAR'])      # => BAD
```

Returns: `boolean`

#### **validate\_array\_member**

This function has been deprecated
It has been replaced by simplib::validate\_array\_member

Validate that the first string (or array) passed is a member of the second
array passed. An optional third argument of i can be passed, which ignores
the case of the objects inside the array.

Examples:

```ruby
validate_array_member('foo',['foo','bar'])     # => true
validate_array_member('foo',['FOO','BAR'])     # => false

#Optional 'i' as third object, ignoring case of FOO and BAR#

validate_array_member('foo',['FOO','BAR'],'i') # => true
```

Returns: `boolean`

#### **validate\_between**

This function has been deprecated
It has been replaced by simplib::validate\_between

Validate that the first value is between the second and third values
numerically.

This is a pure Ruby comparison, not a human comparison.

Returns: `boolean`

#### **validate\_bool\_simp**

This function has been deprecated
It has been replaced by simplib::validate\_bool

Validate that all passed values are either true or false. Abort catalog
compilation if any value fails this check.

Modified from the stdlib validate\_bool to handle the strings 'true' and
'false'.

The following values will pass:

```ruby
$iamtrue = true

validate_bool(true)
validate_bool("false")
validate_bool("true")
validate_bool(true, 'true', false, $iamtrue)
```

The following values will fail, causing compilation to abort:

```ruby
$some_array = [ true ]

validate_bool($some_array)
```

Returns: `boolean`

#### **validate\_deep\_hash**

This function has been deprecated
It has been replaced by simplib::validate\_deep\_hash

Perform a deep validation on two passed hashes.

The first hash is the one to validate against, and the second is the one being
validated. The first hash (i.e. the source) exists to define a valid structure
and potential regular expression to validate against, or to skip an
entry. Arrays of values will match each entry to the given regular expression.
Below are examples of a source hash and a hash to compare against it:

```ruby
    'source' = {
       'foo' => {
         'bar' => {
           #NOTE: Use single quotes for regular expressions
           'baz' => '^\d+$',
           'abc' => '^\w+$',
           'def' => nil #NOTE: not 'nil' in quotes
         },
         'baz' => {
           'xyz' => '^true|false$'
         }
       }
     }

    'to_check' = {
       'foo' => {
         'bar' => {
           'baz' => '123',
           'abc' => [ 'these', 'are', 'words' ],
           'def' => 'Anything will work here!'
         },
         'baz' => {
           'xyz' => 'false'
         }
       }
```

This fails because we expect the value of 'foo' to be a series of digits, not
letters.

Additionally, all keys must be defined in the source hash that is being
validated against. Unknown keys in the hash being compared will cause a

Returns: `boolean`

#### **validate\_float**

This function has been deprecated.

Validates whether or not the passed argument is a float.

Returns: `boolean`

#### **validate\_integer**

This function has been deprecated.

Validates whether or not the passed argument is an integer.

Returns: `boolean`

#### **validate\_macaddress**

This function has been deprecated.

Validate that all passed values are valid MAC addresses.

The following values will pass:

```ruby
$macaddress = 'CA:FE:BE:EF:00:11'

validate_macaddress($macaddress)
validate_macaddress($macaddress,'00:11:22:33:44:55')
validate_macaddress([$macaddress,'00:11:22:33:44:55'])
```

Returns: `boolean`

#### **validate\_port**

This function has been deprecated.
It has been replaced by simplib::validate\_port

Validates whether or not the passed argument is a valid port (i.e.  between
1 - 65535).

The following values will pass:

```puppet
$port = '10541'
$ports = ['5555', '7777', '1', '65535']

validate_port($port)
validate_port($ports)
validate_port('11', '22')
```

The following values will not pass:

```puppet
validate_port('0')
validate_port('65536')
```

Returns: `boolean`

#### **validate\_net\_list**

This function has been deprecated.
It has been replaced by simplib::validate\_net\_list

Validate that a passed list (Array or single String) of networks is filled
with valid IP addresses or hostnames. Hostnames are checked per
[RFC 1123](https://tools.ietf.org/html/rfc1123).Ports appended with a colon (:)
are allowed.

There is a second, optional argument that is a regex of strings that should be
ignored from the list. Omit the beginning and ending '/' delimiters.

The following values will pass:

```ruby
$trusted_nets = ['10.10.10.0/24','1.2.3.4','1.3.4.5:400']
validate_net_list($trusted_nets)

$trusted_nets = '10.10.10.0/24'
validate_net_list($trusted_nets)

$trusted_nets = ['10.10.10.0/24','1.2.3.4','any','ALL']
validate_net_list($trusted_nets,'^(any|ALL)$')
```

The following values will fail:

```ruby
$trusted_nets = '10.10.10.0/24,1.2.3.4'
validate_net_list($trusted_nets)

$trusted_nets = 'bad stuff'
validate_net_list($trusted_nets)
```

Returns: `boolean`

#### **validate\_re\_array**

This function has been deprecated.
It has been replaced by simplib::validate\_re\_array

Perform simple validation of a string, or array of strings, against one or
more regular expressions. The first argument of this function should be a
string to test, and the second argument should be a stringified regular
expression (without the // delimiters) or an array of regular expressions. If
none of the regular expressions match the string passed in, compilation will
abort with a parse error.

If a third argument is specified, this will be the error message raised and
seen by the user.

The following strings will validate against the regular expressions:

```ruby
validate_re_array('one', '^one$')
validate_re_array('one', [ '^one','^two' ])
validate_re_array(['one','two'], [ '^one', '^two' ])
```

The following strings will fail to validate, causing compilation to abort:

```ruby
validate_re_array('one', [ '^two', '^three' ])
```

A helpful error message can be returned like this:

```ruby
validate_re_array($::puppetversion, '^2.7', 'The $puppetversion fact
value does not match 2.7')
```

Returns: `boolean`

#### **validate\_sysctl\_value**

This function has been deprecated.
It has been replaced by simplib::validate\_sysctl\_value

Validate that the passed value is correct for the passed sysctl key.

If a key is not know, simply returns that the value is valid.

Example:

Returns: `boolean`

#### **validate\_umask**

This function has been deprecated.

Validate that the passed value is a valid umask string.

Examples:

```ruby
$val = '0077' validate_umask($val) # => OK

$val = '0078' validate_umask($val) # => BAD
```

Returns: `boolean`

#### **validate\_uri\_list**

This function is deprecated and is replaced by
simplib::validate\_uri\_list

Usage: validate\_uri\_list(\[LIST\],\[\])

Validate that a passed list (Array or single String) of URIs is valid
according to Ruby's URI parser.

The following values will pass:

```ruby
$uris = [http://foo.bar.baz:1234','ldap://my.ldap.server']
validate_uri_list($uris)

$uris = ['ldap://my.ldap.server','ldaps://my.ldap.server']
validate_uri_list($uris,['ldap','ldaps'])
```

Returns: `boolean`

### Types

* [**ftpusers**](#ftpusers)
* [**init_ulimit**](#init_ulimit)
* [**prepend_file_line**](#prepend_file_line)
* [**reboot_notify**](#reboot_notify)
* [**runlevel**](#runlevel)
* [**script_umask**](#script_umask)
* [**simp_file_line**](#simp_file_line)

#### **ftpusers**

Adds all system users to the named file, preserving any other
          entries currently in the file.

*Examples*:
```puppet
    #This will add all users in /etc/passwd with uid < 500
    # and nobody and jim to the file /etc/ftpusers'
    #
    ftpusers { '/etc/ftpusers':
      min_id      => 500,
      always_deny => ['nobody', 'jim'],
      require     => File['/etc/ftpusers']
    }

```
#### **init_ulimit**
This type is for systems that do not support systemd.
It will update the ``ulimit`` settings in init scripts.

*Examples*:
```puppet
# Long Names

    init_ulimit { 'rsyslog':
      ensure     => 'present',
      limit_type => 'both'
      item       => 'max_open_files',
      value      => 'unlimited'
    }

# Short Names

    init_ulimit { 'rsyslog':
      item       => 'n',
      value      => 'unlimited'
    }
```

####  **prepend_file_line**
Type that can prepend whole a line to a file if it does not already contain it.

*Example*:
```puppet
  file_prepend_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => '%admin ALL=(ALL) ALL',
  }
```

#### **reboot_notify**
Notifies users when a system reboot is required.

This type creates a file at $target the contents of which
provide a summary of the reasons why the system requires a
reboot.

NOTE: This type will *only* register entries on refresh. Any
other use of the type will not report the necessary reboot.

A reboot notification will be printed at each puppet run until
the system is successfully rebooted

*Examples*:
```puppet
    reboot_notify { 'selinux':
      reason    => 'A reboot is required to completely modify selinux state',
      subscribe => Selinux_state['set_selinux_state']
    }
```
#### **runlevel**
Changes the system runlevel by re-evaluating the inittab or systemd link.

*Examples*: 
```puppet
  # Set the current level and the default level to mulit-user

  runlevel { '3': persist => true, }

  # Set the current level to graphical

  runlevel { 'graphical':
    persist => false
  }
```
#### **script_umask**
Alters the umask settings in the passed file if a umask line exists.

*Examples*:
```puppet
  script_umask { '/usr/local/myscript.sh':
      umask => 077
  }
```

####  **simp_file_line**
Ensures that a given line is contained within a file.  The implementation
matches the full line, including whitespace at the beginning and end.  If
the line is not contained in the given file, Puppet will add the line to
ensure the desired state.  Multiple resources may be declared to manage
multiple lines in the same file.

This is an enhancement to the stdlib file_line that allows for the
following additional options:
   * prepend     => [binary] Prepend the line instead of appending it if not
                    using 'match'
   * deconflict  => [binary] Do not execute if there is a file resource that
                    already manipulates the content of the target file.

*Examples*:
```puppet

   # This will add both lines to /etc/sudoers
   simp_file_line { 'sudo_rule':
     path => '/etc/sudoers',
     line => '%sudo ALL=(ALL) ALL',
   }
   simp_file_line { 'sudo_rule_nopw':
     path => '/etc/sudoers',
     line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
   }

   # This will not add the line
   file { '/tmp/myfile':
     content => 'junk content',
   }
   simp_file_line { 'junk':
     path => '/tmp/myfile',
     line => 'What a beautiful day'
   }

   # This will  add the line
   file { '/tmp/myfile':
     content => 'junk content',
     replace => false
   }
   simp_file_line { 'junk':
     path => '/tmp/myfile',
     line => 'What a beautiful day'
   }

```

### Data Types

The following Puppet 4 compatible Data Types have been added for convenience
and validation across the SIMP codebase.

* Simplib::EmailAddress
    * Simple e-mail address validator
        * ``foo@bar.com``

* Simplib::Host
    * A single Host or an IP Address
        * ``1.2.3.4``
        * ``my-host.com``

* Simplib::Host::Port
    * A single Host or an IP Address with a Port
        * ``1.2.3.4:80``
        * ``my-host.com:443``

* Simplib::Hostname
    * A hostname, Unicode hostnames are not currently supported
        * ``my-host.com``
        * ``aa.bb``

* Simplib::IP
    * An IP Address
        * ``1.2.3.4``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``

* Simplib::IP::Port
    * An IP Address (V4 or V6) with a Port

* Simplib::IP::V4
    * An IPv4 Address
        * ``1.2.3.4``

* Simplib::IP::CIDR
    * An IPv4 or IPv6 Address with a CIDR Subnet
        * ``1.2.3.4/24``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334/96``

* Simplib::IP::V4::CIDR
    * An IPv4 Address with a CIDR Subnet
        * ``1.2.3.4/24``

* Simplib::IP::V4::DDQ
    * An IPv4 Address with a Dotted Quad Subnet
        * ``1.2.3.4/255.255.0.0``

* Simplib::IP::V4::Port
    * An IPv4 Address with an attached Port
        * ``1.2.3.4:443``

* Simplib::IP::V6
    * An IPv6 Address
        * ``::1``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``
        * ``[::1]``
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]``

* Simplib::IP::V6::Base
    * A regular IPv6 Address
        * ``::1``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``

* Simplib::IP::V6::Bracketed
    * A bracketed IPv6 Address
        * ``[::1]``
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]``

* Simplib::IP::V6::CIDR
    * An IPv6 address with a CIDR subnet
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334/96``

* Simplib::IP::V6::Port
    * An IPv6 address with an attached Port
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]:443``

* Simplib::Netlist
    * An Array of network-relevant entries
        * Hostname
        * IPv4
        * IPv4 with Subnet
        * IPv4 with Port
        * IPv6
        * IPv4 with Subnet
        * IPv4 with Port

* Simplib::Netlist::Host
    * An Array of Hosts
        * Hostname
        * IPv4
        * IPv6

* Simplib::Netlist::IP
    * An Array of IP Addresses
        * IPv4
        * IPv6

* Simplib::Netlist::IP::V4
    * An Array of IPv4 Addresses

* Simplib::Netlist::IP::V6
    * An Array of IPv6 Addresses

* Simplib::Netlist::Port
    * An Array of Hosts with Ports

* Simplib::Port
    * A Port Number

* Simplib::Port::Dynamic
    * Either 49152 or 65535

* Simplib::Port::Random
    * Port 0

* Simplib::Port::System
    * 1-1024

* Simplib::Port::User
    * 1025-49151
    * 49153-65534

* Simplib::Syslog::CFacility
  * A syslog log facility, in the form expected by ``syslog(3)``
    * LOG_KERN
    * LOG_LOCAL6

* Simplib::Syslog::CPriority
  * A syslog log priority, in the form expected by ``syslog(3)``
    * LOG_KERN.LOG_INFO
    * LOG_LOCAL6.LOG_WARNING

* Simplib::Syslog::CSeverity
  * A syslog log severity, in the form expected by ``syslog(3)``
    * LOG_INFO
    * LOG_WARNING

* Simplib::Syslog::Facility
  * A syslog log facility, in either all uppercase or all lowercase.
    * kern
    * local6
    * LOCAL6

* Simplib::Syslog::LowerFacility
  * A syslog log facility, in all lowercase.
    * auth
    * local4

* Simplib::Syslog::UpperFacility
  * A syslog log facility, in all uppercase.
    * MAIL
    * LOCAL7

* Simplib::Syslog::Severity
  * A syslog severity level, in either all uppercase or all lowercase.
    * info
    * WARNING

* Simplib::Syslog::LowerSeverity
  * A syslog severity level, in all lowercase.
    * info
    * emerg

* Simplib::Syslog::UpperSeverity
  * A syslog severity level, in all uppercase.
    * DEBUG
    * WARNING

* Simplib::Syslog::Priority
  * A syslog priority destination, in format 'facility.severity' and in either
    all uppercase or all lowercase. This type only accepts the keyword
    facilities and severities.
    * mail.info
    * KERN.EMERG

* Simplib::Syslog::LowerPriority
  * A syslog priority destination, in format 'facility.severity' and in only
    all lowercase. This type only accepts the keyword
    facilities and severities.
    * mail.info
    * user.err

* Simplib::Syslog::UpperPriority
  * A syslog priority destination, in format 'facility.severity' and in only
    all uppercase. This type only accepts the keyword
    facilities and severities.
    * SYSLOG.WARNING
    * AUTHPRIV.INFO

* Simplib::Umask
    * A valid Umask

* Simplib::URI
    * A valid URI string (lightly sanity checked)

## Development

Please read our [Contribution Guide](http://simp.readthedocs.io/en/master/contributors_guide/index.html)
and visit our [Developer Wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home)

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

[System Integrity Management Platform](https://simp-project.com)

