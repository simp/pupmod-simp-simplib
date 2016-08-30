[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![Build
Status](https://travis-ci.org/simp/pupmod-simp-simplib.svg)](https://travis-ci.org/simp/pupmod-simp-simplib)
[![SIMP
compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

#### Table of Contents

1. [Module Description - What the module does and why it is useful]
(#module-description)
2. [Setup - The basics of getting started with simplib](#setup)
    * [What simplib affects](#what-simplib-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with simplib](#beginning-with-simplib)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how]
(#reference)
    * [Facts](#facts)
    * [Functions](#functions)
    * [Types](#types)
    * [Classes](#classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
      * [Acceptance Tests - Beaker env variables](#acceptance-tests)

## Module Description

simplib is a collection custom functions, facts, and types relevant to SIMP that
are common enough to rate distributing as their own module.

This module is a component of the [System Integrity Management
Platform](https://github.com/NationalSecurityAgency/SIMP), a
compliance-management framework built on Puppet. It is optimally designed for
use within a larger SIMP ecosystem, but many of its functions can be used
independently.

## Setup

### What simplib affects

simplib contains functions, facts, and small utility classes that effect small
things not warranting their own module.

### Setup Requirements

Agents will need to enable `pluginsync`.

## Usage

Please see [reference](#reference) for usage.

## Reference

A list of things provided by simplib is below. Please reference the `doc/`
directory in the top level of the repo or the code itself for more detailed
documentation.

### Facts

  * **acpid_enabled**        -  Return true if ACPI is available on the system
  * **boot_dir_uuid**        -  Return the UUID of the partition holding the
   boot directory
  * **cmdline**              -  Returns the contents of `/proc/cmdline` as a
   hash
  * **cpuinfo**              -  Returns the contents of `/proc/cpuinfo` as a
   hash
  * **defaultgatewayiface**  -  Return the default gw interface of the system
  * **defaultgateway**       -  Return the default gateway of the system
  * **fips_enabled**         -  Determine whether or not FIPS is enabled on
   this system
  * **fullrun**              -  Determine whether or not to do an intensive run
  * **gdm_version**          -  Return the version of GDM that is installed
  * **grub_version**         -  Return the grub version installed on the system
  * **has_clustering**       -  Return true if the clvmd is running
  * **init_systems**         -  Return a list of all init systems present on
   the system
  * **ipv6_enabled**         -  Return true if IPv6 is enabled and false if not
  * **reboot_required**      -  Returns a hash of 'name' => 'reason' entries
  * **runlevel**             -  Return the current system runlevel
  * **shmall**               -  Return the value of shmall from sysctl
  * **tmp_mounts**           -  This fact provides information about `/tmp`,
  `/var/tmp`, and `/dev/shm` should they be present on the system
  * **uid_min**              -  Return the minimum uid allowed

### Functions

- [array\_include](#array_include)
- [array\_size](#array_size)
- [array\_union](#array_union)
- [bracketize](#bracketize)
- [deep\_merge](#deep_merge)
- [generate\_reboot\_msg](#generate_reboot_msg)
- [get\_ports](#get_ports)
- [h2n](#h2n)
- [host\_is\_me](#host_is_me)
- [inspect](#inspect)
- [ipaddresses](#ipaddresses)
- [ip\_is\_me](#ip_is_me)
- [ip\_to\_cron](#ip_to_cron)
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
- [validate\_array\_of\_hashes](#validate_array_of_hashes)
- [validate\_array\_member](#validate_array_member)
- [validate\_between](#validate_between)
- [validate\_bool\_simp](#validate_bool_simp)
- [validate\_deep\_hash](#validate_deep_hash)
- [validate\_float](#validate_float)
- [validate\_integer](#validate_integer)
- [validate\_macaddress](#validate_macaddress)
- [validate\_port](#validate_port)
- [validate\_net\_list](#validate_net_list)
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

Returns: `rvalue`

#### **array\_size**

Returns the number of elements in an array. If a string is passed, simply
returns '1'.

This is in contrast to the Puppet Labs stdlib 'size' function which returns
the size of an array or the length of a string when called.

Returns: `rvalue`

#### **array\_union**

Return the union of two arrays.

Example:

```ruby
$arr_x = ['1','2']
$arr_y = ['2','3','4']

$res = array_union($arr_x, $arr_y)

$res contains: ['1','2','3','4']
```

Returns: `rvalue`

#### **bracketize**

Returns: `rvalue`

#### **deep\_merge**

Perform a deep merge on two passed hashes.

This code is shamelessly stolen from the guts of
ActiveSupport::CoreExtensions::Hash::DeepMerge and munged together with the
Puppet Labs stdlib 'merge' function.

Returns: `rvalue`

#### **generate\_reboot\_msg**

Returns: `rvalue`

#### **get\_ports**

Take an array of items that may contain port numbers and appropriately return
the port portion. Works with hostnames, IPv4, and IPv6.

Arguments: hosts

Returns: `rvalue`

#### **h2n**

Return an IP address for the passed hostname.

Returns: `rvalue`

#### **host\_is\_me**

Detect if a local system identifier Hostname/IP address is contained in the
passed whitespace delimited list. Whitespace and comma delimiters and passed
arrays are accepted. 127.0.0.1 and ::1 are never matched, use 'localhost' or
'localhost6' for that if necessary.

Returns: `rvalue`

#### **inspect**

Prints out Puppet warning messages that display the passed variable.

This is mainly meant for debugging purposes.

Returns: `statement`

#### **ipaddresses**

Return an array of all IP addresses known to be associated with the client. If
an argument is passed, and is not false, then only return non-local addresses.

Returns: `rvalue`

#### **ip\_is\_me**

Detect if an IP address is contained in the passed whitespace delimited list.

Returns: `rvalue`

#### **ip\_to\_cron**

Returns: `rvalue`

#### **join\_mount\_opts**

Merge two sets of 'mount' options in a reasonable fashion. The second set will
always override the first.

Returns: `rvalue`

#### **localuser**

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

Returns: `rvalue`

#### **mapval**

Pull a mapped value from a text file. Must provide a Ruby regex!.

Returns: `rvalue`

#### **nets2cidr**

Convert an array of networks into CIDR notation

Returns: `rvalue`

#### **nets2ddq**

Convert an array of networks into dotted quad notation

Returns: `rvalue`

#### **parse\_hosts**

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

Returns: `rvalue`

#### **passgen**

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

    Returns: password string
```

Returns: `rvalue`

#### **rand\_cron**

Returns: `rvalue`

#### **simp\_version**

Return the version of SIMP that this server is running.

Returns: `rvalue`

#### **slice\_array**

Split an array into an array of arrays that contain groupings of 'max\_length'
size. This is similar to 'each\_slice' in newer versions of Ruby.

```ruby
  * Options *

  to_slice => The array to slice. This will be flattened if necessary.

  max_length => The maximum length of each slice.

  split_char => An optional character upon which to count sub-elements
  as multiples. Only one per subelement is supported.
```

Returns: `rvalue`

#### **strip\_ports**

Take an array of items that may contain port numbers and appropriately return
the non-port portion. Works with hostnames, IPv4, and IPv6.

Arguments: hosts

Returns: `rvalue`

#### **to\_integer**

Converts the argument into an Integer.

Only works if the passed argument responds to the 'to\_i' Ruby method.

Returns: `rvalue`

#### **to\_string**

Converts the argument into a String.

Only works if the passed argument responds to the 'to\_s' Ruby method.

Returns: `rvalue`

#### **validate\_array\_of\_hashes**

Validate that the passed argument is either an empty array or an array that
only contains hashes.

Examples:

```ruby
validate_array_of_hashes([{'foo' => 'bar'}]) # => OK
validate_array_of_hashes([])                 # => OK
validate_array_of_hashes(['FOO','BAR'])      # => BAD
```

Returns: `statement`

#### **validate\_array\_member**

Validate that the first string (or array) passed is a member of the second
array passed. An optional third argument can be passed that has the following
properties when set.

```ruby
'i' =>; Ignore Case
```

Examples:

```ruby
validate_array_member('foo',['foo','bar'])     # => true
validate_array_member('foo',['FOO','BAR'])     # => false
validate_array_member('foo',['FOO','BAR'],'i') # => true
```

Returns: `statement`

#### **validate\_between**

Validate that the first value is between the second and third values
numerically.

This is a pure Ruby comparison, not a human comparison.

Returns: `statement`

#### **validate\_bool\_simp**

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

Returns: `statement`

#### **validate\_deep\_hash**

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

Returns: `statement`

#### **validate\_float**

Validates whether or not the passed argument is a float.

Returns: `statement`

#### **validate\_integer**

Validates whether or not the passed argument is an integer.

Returns: `statement`

#### **validate\_macaddress**

Validate that all passed values are valid MAC addresses.

The following values will pass:

```ruby
$macaddress = 'CA:FE:BA:BE:00:11'

validate_macaddress($macaddress)
validate_macaddress($macaddress,'00:11:22:33:44:55')
validate_macaddress([$macaddress,'00:11:22:33:44:55'])
```

Returns: `statement`

#### **validate\_port**

Validates whether or not the passed argument is a valid port (i.e.  between 1
- 65535).

The following values will pass:

```puppet
$port = '10541'
$ports = ['5555', '7777', '1', '65535']

validate_port($port)
validate_port($ports)
validate_port('11', '22')
```

The following values will not pass: validate\_port('0')

```puppet
validate_port('65536')
```

Returns: `statement`

#### **validate\_net\_list**

Validate that a passed list (Array or single String) of networks is filled
with valid IP addresses or hostnames. Hostnames are checked per
[RFC 1123](https://tools.ietf.org/html/rfc1123).Ports appended with a colon (:)
are allowed.

There is a second, optional argument that is a regex of strings that should be
ignored from the list. Omit the beginning and ending '/' delimiters.

The following values will pass:

```ruby
$client_nets = ['10.10.10.0/24','1.2.3.4','1.3.4.5:400']
validate_net_list($client_nets)

$client_nets = '10.10.10.0/24'
validate_net_list($client_nets)

$client_nets = ['10.10.10.0/24','1.2.3.4','any','ALL']
validate_net_list($client_nets,'^(any|ALL)$')
```

The following values will fail:

```ruby
$client_nets = '10.10.10.0/24,1.2.3.4'
validate_net_list($client_nets)

$client_nets = 'bad stuff'
validate_net_list($client_nets)
```

Returns: `statement`

#### **validate\_re\_array**

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

Returns: `statement`

#### **validate\_sysctl\_value**

Validate that the passed value is correct for the passed sysctl key.

If a key is not know, simply returns that the value is valid.

Example:

Returns: `statement`

#### **validate\_umask**

Validate that the passed value is a valid umask string.

Examples:

```ruby
$val = '0077' validate_umask($val) # => OK

$val = '0078' validate_umask($val) # => BAD
```

Returns: `statement`

#### **validate\_uri\_list**

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

Returns: `statement`

### Types

* **ftpusers**
* **init_ulimit**
* **prepend_file_line**
* **reboot_notify**
* **runlevel**
* **script_umask**
* **simp_file_line**

### Classes

#### Public Classes
* `simplib`

* `simplib::at`

* `simplib::at::add_user`

* `simplib::chkrootkit`

* `simplib::cron`

* `simplib::cron::add_user`

* `simplib::etc_default`

* `simplib::etc_default::nss`

* `simplib::etc_default::useradd`

* `simplib::host_conf`

* `simplib::issue`

* `simplib::incron`

* `simplib::incron::add_user`

* `simplib::incron::add_system_table`

* `simplib::ktune`

* `simplib::libuser_conf`

* `simplib::localusers`

* `simplib::login_defs`

* `simplib::modprobe_blacklist`

* `simplib::nsswitch`

* `simplib::params`

* `simplib::prelink`

* `simplib::profile_settings`

* `simplib::resolv`

* `simplib::secure_mountpoints`

* `simplib::sudoers`

* `simplib::swappiness`

* `simplib::sysconfig`

* `simplib::sysconfig::init`

* `simplib::sysctl`

* `simplib::timezone`

* `simplib::yum_schedule`

## Limitations

SIMP Puppet modules are generally intended to be used on a Red Hat Enterprise
Linux-compatible distribution.

## Development

Please read our [Contribution
Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)
and visit our [Developer
Wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home)

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

[SIMP Contribution
Guidelines](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)

[System Integrity Management
Platform](https://github.com/NationalSecurityAgency/SIMP)

### Acceptance tests

To run the system tests, you need `Vagrant` installed.

You can then run the following to execute the acceptance tests:

```shell bundle exec rake beaker:suites ```

Some environment variables may be useful:

```shell BEAKER_debug=true BEAKER_provision=no BEAKER_destroy=no
BEAKER_use_fixtures_dir_for_modules=yes ```

*  ``BEAKER_debug``: show the commands being run on the STU and their output.
*  ``BEAKER_destroy=no``: prevent the machine destruction after the tests
   finish so you can inspect the state.
*  ``BEAKER_provision=no``: prevent the machine from being recreated.  This can
   save a lot of time while you're writing the tests.
*  ``BEAKER_use_fixtures_dir_for_modules=yes``: cause all module dependencies
   to be loaded from the ``spec/fixtures/modules`` directory, based on the
   contents of ``.fixtures.yml``. The contents of this directory are usually
   populated by ``bundle exec rake spec_prep``. This can be used to run
   acceptance tests to run on isolated networks.
