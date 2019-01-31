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
    * [Stages](#stages)
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

  * Data Types
  * Custom Types and Providers
  * Facts
  * Functions
  * Puppet Extensions
  * Puppet 3 Functions
  * Stages

## Setup

### What simplib affects

simplib contains data types, custom types and providers, facts, functions, and a class
that expands Puppet Stdlib stages.

### Setup Requirements

Agents will need to enable `pluginsync`.

## Usage

Please see [reference](#reference) for usage.

Full documentation can be found in the [module docs](https://simp.github.io/pupmod-simp-simplib)

## Reference

A list of things provided by simplib is below.

Please reference the `doc/` directory in the top level of the repo or the code
itself for more detailed documentation.

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
  * **fips_enabled**         -  Determine whether FIPS is enabled on this system
  * **fullrun**              -  Determine whether to do an intensive run
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
                                `/var/tmp`, and `/dev/shm` should they be present
                                on the system
  * **uid_min**              -  Return the minimum uid allowed

### Functions

- [simplib::assert\_metadata](#simplibassert_metadata)
- [simplib::assert\_optional\_dependency](#simplibassert_optional_dependency)
- [simplib::deprecation](#simplibdeprecation)
- [simplib::filtered](#simplibfiltered)
- [simplib::gen\_random\_password](#simplibgen_random_password)
- [simplib::inspect](#simplibinspect)
- [simplib::ip\_to\_cron](#simplibip_to_cron)
- [simplib::ipaddresses](#simplibipaddresses)
- [simplib::join\_mount\_opts](#simplibjoin_mount_opts)
- [simplib::knockout](#simplibknockout)
- [simplib::ldap::domain\_to\_dn](#simplibldapdomain_to_dn)
- [simplib::lookup](#simpliblookup)
- [simplib::nets2cidr](#simplibnets2cidr)
- [simplib::nets2ddq](#simplibnets2ddq)
- [simplib::parse\_hosts](#simplibparse_hosts)
- [simplib::passgen](#simplibpassgen)
- [simplib::rand\_cron](#simplibrand_cron)
- [simplib::strip\_ports](#simplibstrip_ports)
- [simplib::to\_integer](#simplibto_integer)
- [simplib::to\_string](#simplibto_string)
- [simplib::validate\_array\_member](#simplibvalidate_array_member)
- [simplib::validate\_between](#simplibvalidate_between)
- [simplib::validate\_bool](#simplibvalidate_bool)
- [simplib::validate\_deep\_hash](#simplibvalidate_deep_hash)
- [simplib::validate\_net\_list](#simplibvalidate_net_list)
- [simplib::validate\_port](#simplibvalidate_port)
- [simplib::validate\_re\_array](#simplibvalidate_re_array)
- [simplib::validate\_sysctl\_value](#simplibvalidate_sysctl_value)
- [simplib::validate\_uri\_list](#simplibvalidate_uri_list)


#### simplib::assert\_metadata

Fails a puppet catalog compile if the client system is not compatible
with the module's `metadata.json`

*Arguments*:

* ``module_name`` module name
* ``options``     (Optional) Hash of behavior modifiers for the function

``options`` can be set globally (for all classes that use this
 function) via hieradata and has the following keys:

* ``enable`` If set to `false` disable all validation
* ``os``     Options for OS validation to be done.  Valid keys:

    * ``validate`` Whether to validate the OS settings
    * `` options`` OS validation options. Valid keys:

        * ``release_match`` Type of OS release matching to be done.
          Valid values:

            * ``none``  No match on minor release (default)
            * ``full``  Full release must match
            * ``major`` Only the major release must match

*Returns*: `nil`

*Example*:

```puppet
    simplib::assert_metadata('mymodule')
```

#### simplib::assert\_optional\_dependency

Fails a puppet catalog compile if the client system is not compatible
with a set of dependencies as specified in an optional dependency Hash

*Arguments*:

* ``source_module`` The module for which you are checking the dependencies
* ``target_module`` (Optional) The target dependency to check. If not
  specified, all modules will be checked
* ``dependency_tree`` (Optional) A colon (`:`) separated path that specifies
  the keys for the target dependency Hash

  * Defaults to { 'simp' => 'optional_dependencies' => [{}] }

*Returns*: `nil`

*Example*:
```json
    {
      "name": "my-module",
      "version": "1.2.3",
      "simp":
        "optional_dependencies": [
          {
            "name": "simp/foo",
            "version_requirement": ">= 3.4.5 < 6.7.8"
          }
        ]
     }
```

```puppet
    # Check the current module for all specified dependencies
    simplib::assert_optional_dependency($module_name)

    # Check the current module for the 'foo' dependency
    simplib::assert_optional_dependency($module_name, 'foo')

    # Check the current module for the 'foo' dependency by a specific author
    simplib::assert_optional_dependency($module_name, 'simp/foo')

    # Check the { 'my' => 'deps' => [{}] } dependency target in the current module metadata
    simplib::assert_optional_dependency($module_name, 'simp/foo', 'my:deps')
```

#### **simplib::deprecation**

Function to print deprecation warnings, logging a warning once
for a given key.

Messages can be enabled if the SIMPLIB\_LOG\_DEPRECATIONS
environment variable is set to 'true'.

*Arguments*:

* ``key``      Uniqueness key, which is used to dedupe messages
* ``message``  Message to be printed, file and line info will be
               appended if available.

*Returns*: `nil`

*Example*:

```puppet
  simplib::deprecation('simplib::foo','simplib::foo is deprecated and will be removed in a future version')
  # Writes message to log if SIMPLIB_LOG_DEPRECATIONS is true.
```

#### **simplib::filtered**

Hiera v5 backend that takes a list of allowed hiera key names, and only
returns results from the underlying backend function that match those keys.

This allows hiera data to be delegated to end users in a multi-tenant
environment, without allowing them the ability to override every hiera data
point (and potentially break systems).

#### **simplib::gen_random_password**

Generates a random password string.

Terminates catalog compilation if the password cannot be created within
allotted time.

*Arguments*:

* ``length``          Length of the string to return
* ``complexity``      (Optional) The types of characters to be used in
                      the password;  valid values:

    * ``0``  Use only Alphanumeric characters (safest)
    * ``1``  Use Alphanumeric characters and reasonably safe symbols
    * ``2``  Use any printable ASCII characters

* ``complex_only``    (Optional) Use only the characters explicitly added
                       by the complexity rules
* ``timeout_seconds`` (Optional) Maximum time allotted to generate
                      the password; a value of 0 disables the timeout

*Returns*: `String` Generated password

*Raises*: `RuntimeError` if password cannot be created within allotted
          time

#### **simplib::ipaddresses**

Return an array of all IP addresses known to be associated with the client,
optionally excluding local addresses.

*Arguments*:

* ``only_remote`` (Optional) Whether to exclude local addresses
                  from the return value (e.g., '127.0.0.1').

*Returns*: `Array`

#### **simplib::inspect**

Prints the passed variable's Ruby type and value for debugging purposes.
This uses a ``Notify`` resource to print the information during the
client run.

*Arguments*:

* ``var_name``    The actual name of the variable, fully scoped, as a
                  ``String``.
* ``output_type`` (Optional) The format that you wish to use to display
                  the output during the run.

    * Valid values are ``json``, ``oneline_json`` and ``yaml``.
    *  ``json`` and ``yaml`` result in multi-line message content.
    *  ``oneline_json`` results in single-line message content.

*Returns*: `nil`

*Example*:

```puppet
  class my_test(
    String $var1,
    Hash   $var2
  )
  {
    simplib::inspect('var1')
    simplib::inspect('var2')
    ...
  }
```

#### **simplib::ip_to_cron**

Transforms an IP address to one or more interval values for `cron`.
This can be used to avoid starting a certain cron job at the same
time on all servers.

*Arguments*:

* ``occurs``    (Optional) The occurrence within an interval, i.e.,
                the number of values to be generated for the interval.
* ``max_value`` (Optional) The maximum value for the interval.  The values
                generated will be in the inclusive range [0, max_value].
* ``algorithm`` (Optional) Valid values are ``ip_mod`` and ``sha256``

    * ``ip_mod``: The modulus of the IP number is used as the basis
      for the returned values.  This algorithm works well to create
      cron job intervals for multiple hosts, when the number of hosts
      exceeds the `max_value` and the hosts have largely, linearly-
      assigned IP addresses.

    * ``sha256``: A random number generated using the IP address
      string is the basis for the returned values.  This algorithm
      works well to create cron job intervals for multiple hosts,
      when the number of hosts is less than the ``max_value`` or the
      hosts do not have linearly-assigned IP addresses.

* ``ip``        (Optional) The IP address to use as the basis for the
                generated values.  When ``nil``, the ``ipaddress`` fact
                (IPv4) is used.

*Returns*: `Array[Integer]` Array of integers suitable for use in the
  ``minute`` or ``hour`` cron field.

*Examples*:

  Generate one value for the `minute` cron interval:

```ruby
    simplib::ip_to_cron()
```
  Generate 2 values for the `hour` cron interval, using the 'sha256'
  algorithm and a provided IP address:

```ruby
     simplib::ip_to_cron(2,23,'sha256','10.0.23.45')
```

#### **simplib::join_mount_opts**

Merge two sets of ``mount`` options in a reasonable fashion. The second set will
always override the first.

*Arguments*:

* ``system_mount_opts`` System mount options
* ``new_mount_opts``    New mount options, which will override
                        ``system_mount_opts`` when there are conflicts

*Returns*: `String`

#### **simplib::knockout**

Uses the knockout prefix of ``--`` to remove elements from an array.

*Arguments*:

* ``array``  The array to work on

*Returns*: `Array`

*Example*:

```puppet
  array = [
    'ssh',
    'sudo',
    '--ssh',
  ]
  $result = simplib::knockout(array)
  #
  # returns $result = [ 'sudo' ]
```

#### **simplib::ldap::domain_to_dn**

Generates an LDAP Base DN from a domain.

*Arguments*:

* ``domain``              (Optional) The DNS domain name, defaults to
                          ``domain`` fact
* ``downcase_attributes`` (Optional) Whether to downcase the LDAP
                          attributes

*Returns*: `String`

*Examples*:

  Generate a LDAP Base DN with uppercase attributes:

```puppet
  $ldap_dn = simplib::ldap::domain_to_dn('test.local')

  # returns $ldap_dn = 'DC=test,DC=local'
```

  Generate a LDAP Base DN with lowercase attributes:

```puppet
  $ldap_dn = simplib::ldap::domain_to_dn('test.local', true)
  #  returns $ldap_dn = 'dc=test,dc=local'
```

#### **simplib::lookup**

A function for falling back to global scope variable lookups when the
Puppet 4 ``lookup()`` function cannot find a value.

While ``lookup()`` will stop at the back-end data sources,
``simplib::lookup()`` will check the global scope first to see if the
variable has been defined.

This means that you can pre-declare a class and/or use an ENC and look up the
variable whether it is declared this way or via Hiera or some other back-end.

*Arguments*:

* ``param``   The parameter you wish to look up.
* ``options`` (Optional) Hash of options for regular ``lookup()``
              This **must** follow the syntax rules for the Puppet
              ``lookup( [\<NAME\>], \<OPTIONS HASH\> )`` version of
              ``lookup()``. No other formats are supported!

*Returns*: `Any` The value that is found in the system for the passed
                 parameter

*Examples*:

```puppet
  # No defaults
  simplib::lookup('foo::bar::baz')

  # With a default
  simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana' })

  # With a typed default
  simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana', 'value_type' => String })
```

#### **simplib::nets2cidr**

Take an input list of networks and returns an equivalent `Array` in
CIDR notation.

* Hostnames are passed through untouched.
* Terminates catalog compilation if any input item is not a valid
  network or hostname.

*Arguments*:

* ``networks_list`` List of 1 or more networks in a single string
                    (separated by whitespace, commas, or semicolons)
                    or an array of strings.

*Returns* `Array[String]` Array of networks in CIDR notation

*Example*:

```puppet
  $foo = [ '1.2.0.0/255.255.0.0',
           '2001:db8:85a3::8a2e:370:0/112',
           '1.2.3.4',
           'myhost.test.local' ]

  $cidrs = nets2cidr($foo)
  #
  # returns $cidrs = [ '1.2.0.0/16',
  #                    '2001:db8:85a3::8a2e:370:0/112',
  #                    '1.2.3.4',
  #                    'myhost.test.local'
  #                  ]
```

#### **simplib::nets2ddq**

Tranforms a list of networks into an equivalent array in
dotted quad notation.

* CIDR networks are converted to dotted quad notation networks.
* IP addresses and hostnames are left untouched.
* Terminates catalog compilation if any input item is not a valid
  network or hostname.

*Arguments*:

* ``networks`` List of 1 or more networks in a single string (separated
               by whitespace, commas, or semicolons) or an array of
               strings.

*Returns*: `Array[String]` Converted input

*Raises*:  RuntimeError if any input item is not a valid network
           or hostname

*Example*:

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
  #                   'myhost' ]
```

#### **simplib::parse_hosts**

Convert an `Array` of items that may contain port numbers or protocols
into a structured `Hash` of host information.

* Works with Hostnames as well as IPv4 and IPv6 addresses.
* IPv6 addresses will be returned normalized with square brackets
  around them for clarity.
* Terminates catalog compilation if

    * A valid network or hostname cannot be extracted from all input
      items.
    * Any input item that contains a port specifies an invalid port.

*Arguments*:

* ``hosts`` Array of host entries, where each entry may contain
            a protocol or both a protocol and port

*Returns*: `Hash` Structured Hash of the host information

*Raises*: `RuntimeError` if any input item that contains a port
           specifies an invalid port

*Example*:

```puppet
  # Input with multiple host formats:
  simplib::parse_hosts([ '1.2.3.4',
                         'http://1.2.3.4',
                         'https://1.2.3.4:443' ])
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

#### **simplib::passgen**

Generates/retrieves a random password string or its hash for a
passed identifier.

* Uses `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`
  as the destination directory for password storage.
* The minimum length password that this function will return is `8`
  characters.
* Terminates catalog compilation if the password storage directory
  cannot be created/accessed by the Puppet user, the password cannot
  be created in the allotted time, or files not owned by the Puppet
  user are present in the password storage directory.

*Arguments*:

* ``identifier``     Unique `String` to identify the password usage.
* ``modifier_hash``  (Optional) Hash which may contain any of the following
                     options:

    * ``last``       Whether to return the last generated password
    * ``length``     Length of the new password
    * ``hash``       Whether to return a hash  of the password, instead of
                     the password itself. Valid values are:

        * ``false``
        * ``true`` which is equivalent to ``sha256``
        * ``md5``,
        * ``sha256``
        * ``sha512``

    * ``complexity`` The types of characters to be used in the password;
                     valid values:

        * ``0``  Use only Alphanumeric characters (safest)
        * ``1``  Use Alphanumeric characters and reasonably safe symbols
        * ``2``  Use any printable ASCII characters

*Returns*: `String` Password specified

*Examples*:

```puppet
  # Run simplib::passgen for the first time for an identifier.  This
  # generates a length 34 password, stores it, and returns it in plain text.
  $password = simplib::passgen('myfavpasswd',{'length'=> 34})

  # Request a password hash.  Since a password already exists for this
  # identifier, retrieves the existing password and returns the hash of it.
  $password_hash = simplib::passgen('myfavpasswd',{ hash => 'sha256' })
```

#### **simplib::rand_cron**

Transforms an input string to one or more interval values for `cron`.
This can be used to avoid starting a certain cron job at the same
time on all servers.

*Arguments*:

* ``modifier``    The input string to use as the basis for the
                  generated values
* ``algorithm``   Randomization algorithm to apply to transform the
                  input string; valid values are ``ip_mod`` and ``sha256``

    * ``ip_mod``: The modulus of the IP number is used as the basis
      for the returned values.  This algorithm works well to create
      cron job intervals for multiple hosts, when the number of hosts
      exceeds the `max_value` and the hosts have largely, linearly-
      assigned IP addresses.

    * ``sha256``: A random number generated using the IP address
      string is the basis for the returned values.  This algorithm
      works well to create cron job intervals for multiple hosts,
      when the number of hosts is less than the ``max_value`` or the
      hosts do not have linearly-assigned IP addresses.

* ``occurs``      (Optional) The occurrence within an interval
* ``max_value``   (Optional) The maximum value for the interval

*Returns*: `Array[Integer]` Array of integers suitable for use
            in the ``minute`` or ``hour`` cron field

*Examples*:

```puppet
  # Generate one value for the `minute` cron interval using using sha256
  simplib::rand_cron('myhost.test.local','sha256')

  # Generate 2 values for the `hour` cron interval, using the
  # 'ip_mod' algorithm
  simplib::rand_cron('10.0.6.78', 'ip_mod', 2, 23)
```

#### **simplib::strip_ports**

Extract list of unique hostnames and/or IP addresses from an `Array`
of hosts, each of which may may contain protocols and/or port numbers

Terminates catalog compilation if

* A valid network or hostname cannot be extracted from all input items.
* Any input item that contains a port specifies an invalid port.

*Arguments*:

* ``hosts``  Array of hosts which may contain protocols and port numbers

*Returns*: `Array` Non-port portion of hostnames

*Raises*: `RuntimeError` if any input item that contains a port
           specifies an invalid port

*Example*:

```puppet
  $foo = ['https://mysite.net:8443',
          'http://yoursite.net:8081',
          'https://theirsite.com']

  $bar = strip_ports($foo)

  # results  $bar = ['mysite.net','yoursite.net','theirsite.com']
```

#### **simplib::to_integer**

Converts the argument into an Integer.

Terminates catalog compilation if the argument's class
does not respond to the `to_i()` Ruby method.

*Arguments*:

* ``input`` Item to be converted

*Returns*: `Integer`

*Raises*: `RuntimeError` if any ``input`` does not implement a
          ``to_i()`` method

#### **simplib::to_string**

Converts the argument into a String.

*Arguments*:

* ``input`` Item to be converted

*Returns*: `String`

#### **simplib::validate_array_member**

Validate that an single input is a member of another `Array` or an
`Array` input is a subset of another `Array`.

* The comparison can optionally ignore the case of `String` elements.
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``input``    The input to find in the target array.
* ``target``   The array to search.
* ``modifier`` (Optional) If 'i' ignores case.

*Returns*: `nil`

*Raises*:  RuntimeError if ``input`` is not found in ``target``

*Examples*:

```ruby
  # Passing:
  simplib::validate_array_member('foo',['foo','bar'])
  simplib::validate_array_member('foo',['FOO','BAR'],'i')

  # Failing, causing compilation to abort:
  simplib::validate_array_member(['foo','bar'],['FOO','BAR','BAZ'])
```

#### **simplib::validate_between**

Validate that the first value is between the second and third values
numerically.

* The range is inclusive.
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``value``       Value to validate
* ``min_value``   Minimum value that is valid
* ``max_value``   Maximum value that is valid

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  # Passing:
  simplib::validate_between('-1', -3, 0)
  simplib::validate_between(7, 0, 60)
  simplib::validate_between(7.6, 7.1, 8.4)

  # Failing, causing compilation to abort:
  simplib::validate_between('-1', 0, 3)
  simplib::validate_between(0, 1, 60)
  simplib::validate_between(7.6, 7.7, 8.4)
```

#### **simplib::validate_bool**

Validate that all passed values are either ``true``, 'true',
``false`` or 'false'.

Terminates catalog compilation if validation fails.

*Arguments*:

* ``values_to_validate``   The value to validate.

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```ruby
  # Passing:
  $iamtrue = true
  simplib::validate_bool(true)
  simplib::validate_bool("false")
  simplib::validate_bool("true")
  simplib::validate_bool(true, 'true', false, $iamtrue)

  # Failing, causing compilation to abort:
  simplib::validate_bool('True')
  simplib::validate_bool('FALSE')
```

#### **simplib::validate_deep_hash**

Perform a deep validation on two passed `Hashes`.

* All keys must be defined in the reference `Hash` that is being
  validated against.
* Unknown keys in the `Hash` being compared will cause a failure in
  validation
* All values in the final leaves of the 'reference 'Hash' must
  be a String, Boolean, or nil.
* All values in the final leaves of the `Hash` being compared must
  support a ``to_s()`` method.
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``reference`` Reference Hash to validate against.  Keys at all
                levels of the hash define the structure of the hash
                and the value at each final leaf in the hash tree
                contains a regular expression string, a boolean or
                nil for value validation:

    * When the validation value is a regular expression string, the
      string representation of the ``to_check`` value (from the
      ``to_s()`` method) will be compared to the regular expression
      contained in the reference string.

    * When the validation value is a Boolean, the string representation
      of the ``to_check`` value will be compared with the string
      representation of the Boolean (as provided by the ``to_s()``
      method).

    * When the validation value is a ``nil`` or 'nil', no value
      validation will be done for the key.

    * When the ``to_check`` value contains an ``Array`` of values for
      a key, the validation for that key will be applied to each element
      in that array.

* ``to_check``   Hash to validate against the reference

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  # Passing:
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

  # Failing, causing compilation to abort:
  reference => { 'foo' => '^\d+$' }
  to_check  => { 'foo' => 'abc' }

  simplib::validate_deep_hash(reference, to_check)
```

#### **simplib::validate_port**

Validates whether each passed argument contains valid port(s).

* Each argument can be an individual string, individual integer,
  or an array containing strings and/or integers.
* Each port, numerically, must be in the range [1, 65535].
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``port_args``  A port or array of ports.

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  # Passing
  $port = '10541'
  $ports = [5555, 7777, 1, 65535]

  simplib::validate_port($port)
  simplib::validate_port($ports)
  simplib::validate_port($port, $ports)

  # Failing, causing compilation to abort:
  simplib::validate_port('0')
  simplib::validate_port(65536)
```

#### **simplib::validate_net_list**

Validate that a passed list (`Array` or single `String`) of networks
is filled with valid IP addresses, network addresses (CIDR notation),
or hostnames.

* Hostnames are checked per
  [RFC 1123](https://tools.ietf.org/html/rfc1123).
* Ports appended with a colon `:` are allowed for hostnames and
  individual IP addresses.
* Terminates catalog compilation if validation fails.

*Arguments*:
* ``net_list``   1 or more network to be validated.
* ``str_match``  (Optional) Stringified regular expression (regex
                 without the `//` delimiters)

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  #  Passing
  $trusted_nets = '10.10.10.0/24'
  simplib::validate_net_list($trusted_nets)

  $trusted_nets = '1.2.3.5:400'
  simplib::validate_net_list($trusted_nets)

  $trusted_nets = 'ALL'
  simplib::validate_net_list($trusted_nets,'^(%any|ALL)$')

  # Failing, causing compilation to abort:
  $trusted_nets = '10.10.10.0/24,1.2.3.4'
  simplib::validate_net_list($trusted_nets)

  $trusted_nets = 'bad stuff'
  simplib::validate_net_list($trusted_nets)
```

#### **simplib::validate_re_array**

Perform simple validation of a `String`, or `Array` of `Strings`,
against one or more regular expressions.

* Derived from the Puppet Labs stdlib ``validate_re()``
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``input``   String to be validated
* ``regex``   Stringified regular expression (regex without the `//`
              delimiters)
* ``err_msg`` (Optional) error message to emit upon failure

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  # Passing
  simplib::validate_re_array('one', '^one$')

  # Failing, causing compilation to abort:
  simplib::validate_re_array('one', '^two')

  # Failing with a custom error message
  simplib::validate_re_array($::puppetversion, '^2.7',
    'The $puppetversion fact value does not match 2.7')
```

#### **simplib::validate_sysctl_value**

Validate that the passed value is correct for the passed ``sysctl`` key.

* If a key is not known, simply returns that the value is valid.
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``key``    ``sysctl`` setting whose value is to be validated
* ``value``  Value to be validated

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

#### **simplib::validate_uri_list**

Validate that a passed list (`Array` or single `String`) of URIs is
valid according to Ruby's URI parser.

* **Caution**:  No scheme (protocol type) validation is done if the
  ``scheme_list`` parameter is not set.
* Terminates catalog compilation if validation fails.

*Arguments*:

* ``uri``          URI to be validated.
* ``scheme_list`` (Optional) List of schemes (protocol types) allowed
                  for the URI.

*Returns*: `nil`

*Raises*: `RuntimeError` if validation fails

*Examples*:

```puppet
  # Passing:
  $uris = [http://foo.bar.baz:1234','ldap://my.ldap.server']
  simplib::validate_uri_list($uris)

  $uris = ['ldap://my.ldap.server','ldaps://my.ldap.server']
  simplib::validate_uri_list($uris,['ldap','ldaps'])
```

### Puppet Extensions

The following methods are Puppet extensions in the ``PuppetX::SIMP::Simplib``
namespace:

- [hostname?](#puppetxsimpsimplibhostname)
- [hostname\_only?](#puppetxsimpsimplibhostname_only)
- [human\_sort](#puppetxsimpsimplibhuman_sort)
- [split\_port](#puppetxsimpsimplibsplit_port)

#### **PuppetX::SIMP::Simplib::hostname?**

Determine whether the passed value is a valid hostname, optionally
postpended with ':\<number\>' or '/\<number\>'.

*NOTE*:  This returns true for an IPv4 address, as it conforms to
         RFC 1123.

*Arguments*:

* ``obj`` Input to be assessed

*Returns*: `Boolean` ``false`` if ``obj`` is not comprised of ASCII
           letters (upper or lower case), digits, hypens (except at the
           beginning and end), and dots (except at beginning and end),
           excluding an optional, trailing ':\<number\>' or '/\<number\>'

*Examples*:

```ruby
  # Returns true
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com')
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com:5454')

  # Returns false
  PuppetX::SIMP::Simplib.hostname?('-hostname.me.com')
```

#### **PuppetX::SIMP::Simplib::hostname_only?**

Determine whether the passed value is a valid hostname.

*NOTE*:  This returns true for an IPv4 address, as it conforms to
         RFC 1123.

*Arguments*:

* ``obj`` Input to be assessed

*Returns*: `Boolean` ``false`` if ``obj`` is not comprised of ASCII
           letters (upper or lower case), digits, hypens (except at the
           beginning and end), and dots (except at beginning and end)

*Examples*:

```ruby
  # Returns true
  PuppetX::SIMP::Simplib.hostname_only?('hostname.me.com')

  # Returns false
  PuppetX::SIMP::Simplib.hostname_only?('-hostname.me.com')
  PuppetX::SIMP::Simplib.hostname_only?('hostname.me.com:5454')
```

#### **PuppetX::SIMP::Simplib::human_sort**

Sort a list of values based on usual human sorting semantics.

*Arguments*:

* ``obj`` Enumerable object to be sorted

*Returns*: Sorted object

#### **PuppetX::SIMP::Simplib::split_port**

Split input string into a [ host, port ] pair

*Arguments*:

* ``host_string`` String to be split into host and port

*Returns*: `Array[ host, port ]` Host and port pair

    * Returns ``[ nil, nil ]`` if ``host_string`` is ``nil`` or
      an empty string
    * Returns ``[ host_string, nil ]`` if ``host_string`` is
      a CIDR address or contains no port
    * Port returned is a string

*Examples*:

```ruby
  PuppetX::SIMP::Simplib.split_port('myhost.name:5656')
  # returns ['myhost.name','5656']

  PuppetX::SIMP::Simplib.split_port['192.165.3.9']
  # returns ['192.165.3.9',nil]

  PuppetX::SIMP::Simplib.split_port['192.165.3.9/24']
  # returns ['192.164.3.9/24',nil]

  PuppetX::SIMP::Simplib.split_port('[2001:0db8:85a3:0000:0000:8a2e:0370]:'))
  # returns ['[2001:0db8:85a3:0000:0000:8a2e:0370]',nil]
```

### Puppet 3 Functions

Many of these functions have been deprecated and will be removed in
a future release.  **Do not use these functions in new code.**
Instead, use the newer, environment-safe functions described in
[Functions](#functions). Also, wherever possible, replace the existing
use of these functions with strongly-type parameters, Puppet functions,
or the newer ``simplib`` functions.

When ``simplib`` replacement exists for a function, it will be noted
in the function's description.

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

Returns the number of elements in an array. If a string is passed, simply
returns '1'.

This is in contrast to the Puppet Labs stdlib 'size' function which returns
the size of an array or the length of a string when called.

Returns: `integer`

#### **array\_union**

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

Add brackets to IP addresses and arrays of IP addresses based on the
rules for bracketing IPv6 addresses. Ignore anything that doesn't
look like an IPv6 address.

Returns: `string` or `array`

#### **deep\_merge**

Perform a deep merge on two passed hashes.

This code is shamelessly stolen from the guts of
ActiveSupport::CoreExtensions::Hash::DeepMerge and munged together with the
Puppet Labs stdlib 'merge' function.

Returns: `hash`

#### **filtered**

*This function is deprecated and has been replaced by*
[simplib::filtered](#simplibfiltered).

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

Take an array of items that may contain port numbers and appropriately return
the port portion. Works with hostnames, IPv4, and IPv6.

```
$foo = ['https://mysite.net:8443','http://yoursite.net:8081']

$bar = strip_ports($foo)

$bar contains: ['8443','8081']
```

Returns: `array`

#### **h2n**

Return an IP address for the passed hostname.

Returns: `string`

#### **host\_is\_me**

Detect if a local system identifier Hostname/IP address is contained in the
passed whitespace delimited list. Whitespace and comma delimiters and passed
arrays are accepted. 127.0.0.1 and ::1 are never matched, use 'localhost' or
'localhost6' for that if necessary.

Returns: `boolean`

#### **inspect**

*This function is deprecated and has been replaced by*
[simplib::inspect](#simplibinspect).

Prints out Puppet warning messages that displays the contents of the passed
variable.

This is mainly meant for debugging purposes.

#### **ipaddresses**

*This function is deprecated and has been replaced by*
[simplib::ipaddresses](#simplibipaddresses).

Return an array of all IP addresses known to be associated with the client. If
an argument is passed, and is not false, then only return non-local addresses.

Returns: `array`

#### **ip\_is\_me**

Detect if an IP address is contained in the passed whitespace delimited list.

Returns: `boolean`

#### **ip\_to\_cron**

*This function is deprecated and has been replaced by*
[simplib::ip\_to\_cron](#simplibip_to_cron).

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

*This function is deprecated and has been replaced by*
[simplib::join\_mount\_opts](#simplibjoin_mount_opts).

Merge two sets of 'mount' options in a reasonable fashion. The second set will
always override the first.

Returns: `string`

#### **localuser**

Pull a pre-set password from a password list and return an array of user
details associated with the passed hostname.

If the password starts with the string '\$1\$' and the length is 34
characters, then it will be assumed to be an MD5 hash to be directly applied
to the system.

If the password is in plain text form, then it will be hashed and stored back
into the source file for future use. The plain text version will be commented
out in the file.

*Arguments*:
* ``filename`` Path to the file containing the local users
* ``hostname`` Host that you are trying to match against

*Returns*: `array`

#### **mapval**

Pull a mapped value from a text file. Must provide a Ruby regex!.

*Returns*: `string`

#### **nets2cidr**

*This function is deprecated and has been replaced by*
[simplib::nets2cidr](#simplibnets2cidr).

Convert an array of networks into CIDR notation

Returns: `array`

#### **nets2ddq**

*This function is deprecated and has been replaced by*
[simplib::nets2ddq](#simplibnets2ddq).

Convert an array of networks into dotted quad notation

Returns: `array`

#### **parse\_hosts**

*This function is deprecated and has been replaced by*
[simplib::parse\_hosts](#simplibparse_hosts).

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

*This function is deprecated and has been replaced by*
[simplib::passgen](#simplibpassgen).

Generates a random password string for a passed identifier. Uses
Puppet\[:environmentpath\]/\$environment/simp_autofiles/gen_passwd/ as the
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

*This function is deprecated and has been replaced by*
[simplib::rand\_cron](#simplibrand_cron).

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

Return the version of SIMP that this server is running.

Returns: `string`

#### **slice\_array**

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

*This function is deprecated and has been replaced by*
[simplib::strip\_ports](#simplibstrip_ports).

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

*This function is deprecated and has been replaced by*
[simplib::to\_integer](#simplibto_integer).

Converts the argument into an Integer.

Only works if the passed argument responds to the ``to_i()`` Ruby method.

Returns: `integer`

#### **to\_string**

*This function is deprecated and has been replaced by*
[simplib::to\_string](#simplibto_string).

Converts the argument into a String.

Only works if the passed argument responds to the ``to_s()`` Ruby method.

Returns: `string`

#### **validate\_array\_of\_hashes**

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

*This function is deprecated and has been replaced by*
[simplib::validate\_array\_member](#simplibvalidate_array_member)

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

*This function is deprecated and has been replaced by*
[simplib::validate\_between](#simplibvalidate_between)

Validate that the first value is between the second and third values
numerically.

This is a pure Ruby comparison, not a human comparison.

Returns: `boolean`

#### **validate\_bool\_simp**

*This function is deprecated and has been replaced by*
[simplib::validate\_bool](#simplibvalidate_bool)

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

*This function is deprecated and has been replaced by*
[simplib::validate\_deep\_hash](#simplibvalidate_deep_hash)

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

Validates whether the passed argument is a float.

Returns: `boolean`

#### **validate\_integer**

Validates whether the passed argument is an integer.

Returns: `boolean`

#### **validate\_macaddress**

*This function is deprecated and has been replaced by*
``Simplib::Macaddress`` data type.

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

*This function is deprecated and has been replaced by*
[simplib::validate\_port](#simplibvalidate_port)

Validates whether the passed argument is a valid port (i.e.  between
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

*This function is deprecated and has been replaced by*
[simplib::validate\_net\_list](#simplibvalidate_net_list)

Validate that a passed list (Array or single String) of networks is filled
with valid IP addresses or hostnames. Hostnames are checked per
[RFC 1123](https://tools.ietf.org/html/rfc1123). Ports appended with a colon (:)
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

*This function is deprecated and has been replaced by*
[simplib::validate\_re\_array](#simplibvalidate_re_array)

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

*This function is deprecated and has been replaced by*
[simplib::validate\_sysctl\_value](#simplibvalidate_sysctl_value)

Validate that the passed value is correct for the passed sysctl key.

If a key is not know, simply returns that the value is valid.

Example:

Returns: `boolean`

#### **validate\_umask**

*This function is deprecated and has been replaced by*
``Simplib::Umask`` data type.

Validate that the passed value is a valid umask string.

Examples:

```ruby
$val = '0077' validate_umask($val) # => OK

$val = '0078' validate_umask($val) # => BAD
```

Returns: `boolean`

#### **validate\_uri\_list**

*This function is deprecated and has been replaced by*
[simplib::validate\_uri\_list](#simplibvalidate_uri_list)

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

*Example*:

```puppet
  # This will add all users in /etc/passwd with uid < 500
  # and 'nobody' and 'jim' to the file '/etc/ftpusers'
  #
  ftpusers { '/etc/ftpusers':
    min_id      => 500,
    always_deny => ['nobody', 'jim'],
    require     => File['/etc/ftpusers']
  }
```
#### **init_ulimit**

**This type is for systems that do not support ``systemd``.**

Updates the ``ulimit`` settings in init scripts.

*Examples*:
```puppet
  # limit long name
  init_ulimit { 'rsyslog':
    ensure     => 'present',
    limit_type => 'both'
    item       => 'max_open_files',
    value      => 'unlimited'
  }

  # limit short name
  init_ulimit { 'rsyslog':
    item       => 'n',
    value      => 'unlimited'
  }
```

#### **prepend_file_line**

Prepends a whole line to a file, if the file does not already contain
the line.

*Example*:

```puppet
  file_prepend_line { 'sudo_rule':
    path => '/etc/sudoers',
    line => '%admin ALL=(ALL) ALL',
  }
```

#### **reboot_notify**

Notifies users when a system reboot is required.

* This type creates a file with contents that provide a summary
  of the reasons why the system requires a reboot.
* This type will *only* register entries on refresh. Any
  other use of the type will not report the necessary reboot.
* A reboot notification will be printed at each Puppet run until
  the system is successfully rebooted

*Examples*:

```puppet
  reboot_notify { 'selinux':
    reason    => 'A reboot is required to completely modify selinux state',
    subscribe => Selinux_state['set_selinux_state']
  }
```
#### **runlevel**

Changes the system runlevel by re-evaluating the ``inittab`` or ``systemd`` link.

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

Alters the umask settings in the passed file, if a umask line exists.

*Examples*:

```puppet
  script_umask { '/usr/local/myscript.sh':
      umask => 077
  }
```

#### **simp_file_line**

Ensures that a given line is contained within a file.  The implementation
matches the full line, including whitespace at the beginning and end.  If
the line is not contained in the given file, Puppet will add the line to
ensure the desired state.  Multiple resources may be declared to manage
multiple lines in the same file.

This is an enhancement to the stdlib ``file_line`` that allows for the
following additional options:

   * ``prepend``    Whether to prepend the line instead of appending it,
                    if not using the ``match`` option.
   * ``deconflict`` Whether to not execute if there is a file resource that
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
and validation across the SIMP code base.

* ``Simplib::Domain``
    * Valid DNS domain names (RFC 3696, Section 2). Examples:
        * ``example.com``

* ``Simplib::Domainlist``
    * List of valid domains (RFC 3696, Section 2)

* ``Simplib::EmailAddress``
    * Simple e-mail address validator. Examples:
        * ``foo@bar.com``

* ``Simplib::Host``
    * A single Host or an IP Address. Examples:
        * ``1.2.3.4``
        * ``my-host.com``

* ``Simplib::Host::Port``
    * A single Host or an IP Address with a Port. Examples:
        * ``1.2.3.4:80``
        * ``my-host.com:443``

* ``Simplib::Hostname``
    * A hostname, Unicode hostnames are not currently supported.
      Examples:
        * ``my-host.com``
        * ``aa.bb``

* ``Simplib::Hostname::Port``
    * A single Hostname with a Port. Examples:
        * ``my-host.com:443``

* ``Simplib::IP``
    * An IP Address. Examples:
        * ``1.2.3.4``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``

* ``Simplib::IP::CIDR``
    * An IPv4 or IPv6 Address with a CIDR Subnet. Examples:
        * ``1.2.3.4/24``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334/96``

* ``Simplib::IP::Port``
    * An IP Address (V4 or V6) with a Port. Examples:
        * ``1.2.3.4:80``
        * ``[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443``

* ``Simplib::IP::V4``
    * An IPv4 Address. Examples:
        * ``1.2.3.4``

* ``Simplib::IP::V4::CIDR``
    * An IPv4 Address with a CIDR Subnet. Examples:
        * ``1.2.3.4/24``

* ``Simplib::IP::V4::DDQ``
    * An IPv4 Address with a Dotted Quad Subnet. Examples:
        * ``1.2.3.4/255.255.0.0``

* ``Simplib::IP::V4::Port``
    * An IPv4 Address with an attached Port. Examples:
        * ``1.2.3.4:443``

* ``Simplib::IP::V6``
    * An IPv6 Address. Examples:
        * ``::1``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``
        * ``[::1]``
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]``

* ``Simplib::IP::V6::Base``
    * A regular IPv6 Address. Examples:
        * ``::1``
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334``

* ``Simplib::IP::V6::Bracketed``
    * A bracketed IPv6 Address. Examples:
        * ``[::1]``
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]``

* ``Simplib::IP::V6::CIDR``
    * An IPv6 address with a CIDR subnet. Examples:
        * ``2001:0db8:85a3:0000:0000:8a2e:0370:7334/96``

* ``Simplib::IP::V6::Port``
    * An IPv6 address with an attached Port. Examples:
        * ``[2001:0db8:85a3:0000:0000:8a2e:0370:7334]:443``

* ``Simplib::Macaddress``
    * A MAC address. Examples:
        * ``CA:FE:BE:EF:00:11``
        * ``ca:fe:be:ef:00:11``

* ``Simplib::Netlist``
    * An Array of network-relevant entries
        * Hostname
        * IPv4
        * IPv4 with Subnet
        * IPv4 with Port
        * IPv6
        * IPv4 with Subnet
        * IPv4 with Port

* ``Simplib::Netlist::Host``
    * An Array of Hosts
        * Hostname
        * IPv4
        * IPv6

* ``Simplib::Netlist::IP``
    * An Array of IP Addresses
        * IPv4
        * IPv6

* ``Simplib::Netlist::IP::V4``
    * An Array of IPv4 Addresses

* ``Simplib::Netlist::IP::V6``
    * An Array of IPv6 Addresses

* ``Simplib::Netlist::Port``
    * An Array of Hosts with Ports

* ``Simplib::PackageEnsure``
    * Valid ``ensure`` values for a ``Package`` resource. Examples:
        * ``absent``
        * ``latest``

* ``Simplib::Port``
    * A Port Number

* ``Simplib::Port::Dynamic``
    * Port in the unprivileged port range [49152, 65535]

* ``Simplib::Port::Random``
    * Port ``0`` which has different behaviors but usually binds to
      a random port

* ``Simplib::Port::System``
    * Port in the system privileged port range [1, 1024]

* ``Simplib::Port::User``
    * Port available to users in the unprivileged port ranges [1025, 49151]
      and [49153, 65534]

* ``Simplib::Puppet::Metadata::OS_support``
    * The 'operating\_support' data structure in a Puppet module's
      ``metadata.json``

* ``Simplib::Serverdistribution``
    * Valid options for a Puppet server distribution
        * ``PC1``
        * ``PE``

* ``Simplib::ShadowPass``
    * Valid options for the password field of /etc/shadow to include
      locked passwords, unestablished passwords, and hashed passwords
      using MD5, Blowfish, SHA256, or SHA512 algorithms.

* ``Simplib::Syslog::CFacility``
    * A syslog log facility, in the form expected by ``syslog(3)``.
      Examples:
        * ``LOG_KERN``
        * ``LOG_LOCAL6``

* ``Simplib::Syslog::CPriority``
    * A syslog log priority, in the form expected by ``syslog(3)``.
      Examples:
        * ``LOG_KERN.LOG_INFO``
        * ``LOG_LOCAL6.LOG_WARNING``

* ``Simplib::Syslog::CSeverity``
    * A syslog log severity, in the form expected by ``syslog(3)``.
      Examples:
        * ``LOG_INFO``
        * ``LOG_WARNING``

* ``Simplib::Syslog::Facility``
    * A syslog log facility, in either all uppercase or all lowercase..
      Examples:
        * ``kern``
        * ``local6``
        * ``LOCAL6``

* ``Simplib::Syslog::LowerFacility``
    * A syslog log facility, in all lowercase. Examples:
        * ``auth``
        * ``local4``

* ``Simplib::Syslog::UpperFacility``
    * A syslog log facility, in all uppercase. Examples:
        * ``MAIL``
        * ``LOCAL7``

* ``Simplib::Syslog::Severity``
    * A syslog severity level, in either all uppercase or all lowercase.
      Examples:
        * ``info``
        * ``WARNING``

* ``Simplib::Syslog::LowerSeverity``
    * A syslog severity level, in all lowercase. Examples:
        * ``info``
        * ``emerg``

* ``Simplib::Syslog::UpperSeverity``
    * A syslog severity level, in all uppercase. Examples:
        * ``DEBUG``
        * ``WARNING``

* ``Simplib::Syslog::Priority``
    * A syslog priority destination, in format 'facility.severity' and
      in either all uppercase or all lowercase. This type only accepts
      the keyword facilities and severities. Examples:
        * ``mail.info``
        * ``KERN.EMERG``

* ``Simplib::Syslog::LowerPriority``
    * A syslog priority destination, in format 'facility.severity' and
      in only all lowercase. This type only accepts the keyword
      facilities and severities. Examples:
        * ``mail.info``
        * ``user.err``

* ``Simplib::Syslog::UpperPriority``
    * A syslog priority destination, in format 'facility.severity' and
      in only all uppercase. This type only accepts the keyword
      facilities and severities. Examples:
        * ``SYSLOG.WARNING``
        * ``AUTHPRIV.INFO``

* ``Simplib::Umask``
    * A valid Umask

* ``Simplib::URI``
    * A valid URI string (lightly sanity checked)

### Stages

 ``simplib::stages`` are added to ensure that anyone using the ``stdlib`` stages are not
 tripped up by any SIMP modules that may enable, or disable, various system,
 components; particularly ones that require a reboot.

 Added Stages:

   * ``simp_prep`` -> Comes before ``stdlib``'s ``setup`` stage
   * ``simp_finalize`` -> Comes after ``stdlib``'s ``deploy`` stage

## Development

Please read our [Contribution Guide](http://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

[System Integrity Management Platform](https://simp-project.com)

