[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-simplib.svg)](https://travis-ci.org/simp/pupmod-simp-simplib)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Setup](#setup)
  * [What simplib affects](#what-simplib-affects)
  * [Setup Requirements](#setup-requirements)
* [Usage](#usage)
* [Reference](#reference)
  * [Facts](#facts)
  * [Functions](#functions)
  * [Resource types](#resource-types)
  * [Run stages](#run-stages)
  * [Type aliases (Data types)](#type-aliases-data-types)
  * [Puppet extensions](#puppet-extensions)
    * [**PuppetX::SIMP::Simplib::hostname?**](#puppetxsimpsimplibhostname)
    * [**PuppetX::SIMP::Simplib::hostname_only?**](#puppetxsimpsimplibhostname_only)
    * [**PuppetX::SIMP::Simplib::human_sort**](#puppetxsimpsimplibhuman_sort)
    * [**PuppetX::SIMP::Simplib::split_port**](#puppetxsimpsimplibsplit_port)
* [Development](#development)

<!-- vim-markdown-toc -->
## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

## Module Description

*simp/simplib* provides a standard library of resources for SIMP modules.

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

See [REFERENCE.md](https://github.com/simp/pupmod-simp-simplib/blob/master/REFERENCE.md)

### Resource types

See [REFERENCE.md](https://github.com/simp/pupmod-simp-simplib/blob/master/REFERENCE.md)

### Run stages

See [REFERENCE.md#simplibstages](https://github.com/simp/pupmod-simp-simplib/blob/master/REFERENCE.md#simplibstages)

### Type aliases (Data types)

The following Puppet 4-compatible Type Aliases have been added for convenience
and validation across the SIMP code base:

* ``Simplib::Cron::Hour``
    * Valid list of Simplib::Cron::Hour

* ``Simplib::Cron::Hour_entry``
    * Valid Cron Hour parameter. Examples:
        * ``12``
        * ``'12'``
        * ``*``
        * ``*/5``
        * ``'12-23'``
        * ``'12-23/2'``

* ``Simplib::Cron::Minute``
    * Valid list of Simplib::Cron::Minute

* ``Simplib::Cron::Minute_entry``
    * Valid Cron Minute parameter. Examples:
        * ``12``
        * ``'12'``
        * ``'*'``
        * ``'*/5'``
        * ``'12-23'``
        * ``'12-23/2'``

* ``Simplib::Cron::Month``
    * Valid list of Simplib::Cron::Month

* ``Simplib::Cron::Month_entry``
    * Valid Cron Month parameter. Examples:
        * ``12``
        * ``'12'``
        * ``'*'``
        * ``'*/5'``
        * ``'2-8'``
        * ``'JAN'``
        * ``'jan'``
        * ``'2-12/2'``

* ``Simplib::Cron::MonthDay``
    * Valid list of Simplib::Cron::MonthDay

* ``Simplib::Cron::MonthDay_entry``
    * Valid Cron MonthDay parameter. Examples:
        * ``12``
        * ``'12'``
        * ``'*'``
        * ``'*/5'``
        * ``'12-23'``
        * ``'12-23/2'``

* ``Simplib::Cron::WeekDay``
    * Valid list of Simplib::Cron::WeekDay

* ``Simplib::Cron::WeekDay_entry``
    * Valid Cron WeekDay parameter. Examples:
        * ``0``
        * ``7`` #Sunday can be either 0 or 7
        * ``'2'``
        * ``'TUE'``
        * ``'tue'``
        * ``'*'``
        * ``'*/5'``
        * ``'2-6/2'``
        * ``'2-5'``

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


### Puppet extensions

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
## Development

Please read our [Contribution
Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

