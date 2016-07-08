[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-simplib.svg)](https://travis-ci.org/simp/pupmod-simp-simplib) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with simplib](#setup)
    * [What simplib affects](#what-simplib-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with simplib](#beginning-with-simplib)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Available Facts](#available-facts)
    * [Available Functions](#available-functions)
    * [Available Types and Providers](#available-types-and-providers)
    * [Available Classes](#available-classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
      * [Acceptance Tests - Beaker env variables](#acceptance-tests)

## Overview

A collection of common SIMP functions, facts, and puppet code.


## This is a SIMP module
This module is a component of the [System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP), a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP) and visit our [developer wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).

This module is optimally designed for use within a larger SIMP ecosystem, but many of its functions can be used independently.


## Module Description

This module collects custom functions, facts, and types relevant to SIMP that are common enough to rate distributing as their own module.

## Setup

### What simplib affects

* Presently, simplib does not manage resource on its own.  Its only Puppet-relevant content is ruby code under the `lib/` directory.

### Setup Requirements

* pupmod-simp-compliance_markup

### Setup Requirements **OPTIONAL**

* puppetlabs-stdlib

### Beginning with simplib

The only thing necessary to begin using simplib is to install it into your modulepath.  Agents will need to enable `pluginsync`.

## Usage

**FIXME:** The text below is boilerplate copy.  Ensure that it is correct and remove this message!

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

## Reference

A list of things provided by simplib is below. Please reference the `doc/` directory in the top level of the repo or the code itself for more detailed documentation.

### Available facts:

  * **acpid_enabled**        -  Return true if ACPI is available on the system
  * **boot_dir_uuid**        -  Return the UUID of the partition holding the /boot directory
  * **cmdline**              -  Returns the contents of `/proc/cmdline` as a hash
  * **cpuinfo**              -  Returns the contents of `/proc/cpuinfo` as a hash
  * **defaultgatewayiface**  -  Return the default gateway of the system
  * **defaultgateway**       -  Return the default gw interface of the system
  * **fips_enabled**         -  Determine whether or not FIPS is enabled on this system
  * **fullrun**              -  Determine whether or not to do an intensive run
  * **gdm_version**          -  Return the version of GDM that is installed
  * **grub_version**         -  Return the grub version installed on the system
  * **has_clustering**       -  Return true if the clvmd is running
  * **init_systems**         -  Return a list of all init systems present on the system
  * **ipv6_enabled**         -  Return true if IPv6 is enabled and false if not
  * **reboot_required**      -  Returns a hash of 'name' => 'reason' entries
  * **runlevel**             -  Return the current system runlevel
  * **shmall**               -  Return the value of shmall from sysctl
  * **tmp_mounts**           -  This fact provides information about `/tmp`, `/var/tmp`, and `/dev/shm` should they be present on the system
  * **uid_min**              -  Return the minimum uid allowed

### Available Functions:

  * (rvalue)     -  **array_include**
  * (rvalue)     -  **array_size**
  * (rvalue)     -  **array_union**
  * (rvalue)     -  **bracketize**
  * (rvalue)     -  **deep_merge**
  * (rvalue)     -  **generate_reboot_msg**
  * (rvalue)     -  **get_ports**
  * (rvalue)     -  **h2n**
  * (rvalue)     -  **host_is_me**
  * (rvalue)     -  **ip_is_me**
  * (rvalue)     -  **ip_to_cron**
  * (rvalue)     -  **ipaddresses**
  * (rvalue)     -  **join_mount_opts**
  * (rvalue)     -  **localuser**
  * (rvalue)     -  **mapval**
  * (rvalue)     -  **nets2cidr**
  * (rvalue)     -  **nets2ddq**
  * (rvalue)     -  **parse_hosts**
  * (rvalue)     -  **passgen**
  * (rvalue)     -  **rand_cron**
  * (rvalue)     -  **simp_version**
  * (rvalue)     -  **slice_array**
  * (rvalue)     -  **strip_ports**
  * (rvalue)     -  **to_integer**
  * (rvalue)     -  **to_string**
  * (statement)  -  **inspect**
  * (statement)  -  **validate_array_member**
  * (statement)  -  **validate_array_of_hashes**
  * (statement)  -  **validate_between**
  * (statement)  -  **validate_bool_simp**
  * (statement)  -  **validate_deep_hash**
  * (statement)  -  **validate_float**
  * (statement)  -  **validate_integer**
  * (statement)  -  **validate_macaddress**
  * (statement)  -  **validate_net_list**
  * (statement)  -  **validate_port**
  * (statement)  -  **validate_re_array**
  * (statement)  -  **validate_sysctl_value**
  * (statement)  -  **validate_umask**
  * (statement)  -  **validate_uri_list**

### Available Types and Providers

* **ftpusers**
* **init_ulimit**
* **prepend_file_line**
* **reboot_notify**
* **runlevel**
* **script_umask**
* **simp_file_line**

### Available Classes

  * simplib
    * at
      * add_user
    * chkrootkit
    * cron
      * add_user
    * etc_default
      * nss
      * useradd
    * host_conf
    * issue
    * incron
      * add_user
      * add_system_table
    * ktune
    * libuser_conf
    * localusers
    * login_defs
    * modprobe_blacklist
    * nsswitch
    * params
    * prelink
    * profile_settings
    * resolv
    * secure_mountpoints
    * sudoers
    * swappiness
    * sysconfig
      * init
    * sysctl
    * timezone
    * yum_schedule

## Limitations

**FIXME:** The text below is boilerplate copy.  Ensure that it is correct and remove this message!

SIMP Puppet modules are generally intended to be used on a Redhat Enterprise Linux-compatible distribution such as EL6 and EL7.

## Development

Please see the [SIMP Contribution Guidelines](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP).


### Acceptance tests

To run the system tests, you need [Vagrant](https://www.vagrantup.com/) installed. Then, run:

```shell
bundle exec rake acceptance
```

Some environment variables may be useful:

```shell
BEAKER_debug=true
BEAKER_provision=no
BEAKER_destroy=no
BEAKER_use_fixtures_dir_for_modules=yes
```

* `BEAKER_debug`: show the commands being run on the STU and their output.
* `BEAKER_destroy=no`: prevent the machine destruction after the tests finish so you can inspect the state.
* `BEAKER_provision=no`: prevent the machine from being recreated. This can save a lot of time while you're writing the tests.
* `BEAKER_use_fixtures_dir_for_modules=yes`: cause all module dependencies to be loaded from the `spec/fixtures/modules` directory, based on the contents of `.fixtures.yml`.  The contents of this directory are usually populated by `bundle exec rake spec_prep`.  This can be used to run acceptance tests to run on isolated networks.
