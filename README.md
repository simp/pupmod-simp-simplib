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
    * [Data Types](#data-types)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

simplib is a collection custom functions, facts, and small types.

This module is a component of the [System Integrity Management
Platform](https://github.com/NationalSecurityAgency/SIMP), a
compliance-management framework built on Puppet. It is optimally designed for
use within a larger SIMP ecosystem, but many of its functions can be used
independently.

## Setup

### What simplib affects

simplib contains functions, facts, and small utility classes.

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

Prints out Puppet warning messages that display the passed variable.

This is mainly meant for debugging purposes.

Returns: `string`

#### **ipaddresses**

Return an array of all IP addresses known to be associated with the client. If
an argument is passed, and is not false, then only return non-local addresses.

Returns: `array`

#### **ip\_is\_me**

Detect if an IP address is contained in the passed whitespace delimited list.

Returns: `boolean`

#### **ip\_to\_cron**

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

#### **join\_mount\_opts**

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

Arguments:
* filename (path to the file containing the local users)
* hostname (host that you are trying to match against)

Returns: `array`

#### **mapval**

Pull a mapped value from a text file. Must provide a Ruby regex!.

Returns: `string`

#### **nets2cidr**

Convert an array of networks into CIDR notation

Returns: `array`

#### **nets2ddq**

Convert an array of networks into dotted quad notation

Returns: `array`

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

Returns: `hash`

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
```

Returns: `string`

#### **rand\_cron**

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

Split an array into an array of arrays that contain groupings of 'max\_length'
size. This is similar to 'each\_slice' in newer versions of Ruby.

```ruby
  * Options *

  to_slice => The array to slice. This will be flattened if necessary.

  max_length => The maximum length of each slice.

  split_char => An optional character upon which to count sub-elements
  as multiples. Only one per subelement is supported.
```

Returns: `array of arrays`

#### **strip\_ports**

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

Converts the argument into an Integer.

Only works if the passed argument responds to the 'to\_i' Ruby method.

Returns: `integer`

#### **to\_string**

Converts the argument into a String.

Only works if the passed argument responds to the 'to\_s' Ruby method.

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

Validate that the first value is between the second and third values
numerically.

This is a pure Ruby comparison, not a human comparison.

Returns: `boolean`

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

Returns: `boolean`

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

Returns: `boolean`

#### **validate\_float**

Validates whether or not the passed argument is a float.

Returns: `boolean`

#### **validate\_integer**

Validates whether or not the passed argument is an integer.

Returns: `boolean`

#### **validate\_macaddress**

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

Validate that the passed value is correct for the passed sysctl key.

If a key is not know, simply returns that the value is valid.

Example:

Returns: `boolean`

#### **validate\_umask**

Validate that the passed value is a valid umask string.

Examples:

```ruby
$val = '0077' validate_umask($val) # => OK

$val = '0078' validate_umask($val) # => BAD
```

Returns: `boolean`

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

Returns: `boolean`

### Types

* **ftpusers**
* **init_ulimit**
* **prepend_file_line**
* **reboot_notify**
* **runlevel**
* **script_umask**
* **simp_file_line**

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

