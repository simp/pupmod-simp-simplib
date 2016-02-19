Summary: A collection of common SIMP functions, facts, and puppet code
Name: pupmod-simplib
Version: 1.0.1
Release: 2
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppetlabs-stdlib
Requires: puppet >= 3.3.0
Buildarch: noarch
Obsoletes: pupmod-common < 5.0.0
Provides: pupmod-common = 5.0.0-0
Obsoletes: pupmod-functions < 3.0.0
Provides: pupmod-functions = 3.0.0-0
Requires: pupmod-onyxpoint-compliance_markup

Prefix: %{_sysconfdir}/puppet/environments/simp/modules

%description
A collection of common SIMP functions, files, facts, and types

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/simplib

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/simplib
done

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/simplib

%files
%defattr(0640,root,puppet,0750)
%{prefix}/simplib

%post
#!/bin/sh

%postun
# Post uninstall stuff

%changelog
* Fri Feb 19 2016 Ralph Wright <ralph.wright@onyxpoint.com> - 1.0.1-2
- Added compliance function support

* Tue Feb 02 2016 Chris Tessmer <chris.tessmer@onyxpoint.com> - 1.0.1-1
- Removed `os_bugfixes` and `bugfix1049656`.

* Fri Jan 08 2016 Chris Tessmer <chris.tessmer@onyxpoint.com> - 1.0.1-0
- Confined Linux facts that were causing errors during Windows agent runs

* Thu Dec 24 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0.0-3
- Removed the simp_enabled fact as it is not needed.

* Thu Dec 17 2015 Nick Markowski <nmarkowski@keywcorp.com> - 1.0.0-2
- CCE-18455-6, CCE-3562-6 disable ipv6.  Ipv6 remains enabled at
  the kernel level, but is functionally disabled via sysctl when
  ipv6_enabled = false.

* Thu Dec 10 2015 Nick Markowski <nmarkowski@keywcorp.com> - 1.0.0-1
- CCE-4241-6 Single user mode is now password protected.
- Added a simp_enabled fact to return true if the 'simp' class is in the catalog.

* Thu Nov 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0.0-0
- Added validate_uri_list function
- Ensure that nsswitch works properly for SSSD
- Add sudoers support for SSSD and nsswitch

* Fri Nov 13 2015 Chris Tessmer <chris.tessmer@onyxpoint.com> - 1.0.0-0
- Imported manifests/ template/ and files/ assets from pupmod-common
- manifests/ assets from pupmod-functions are deprecated and will not be imported
- All tests pass; first version is rolled up

* Tue Oct 13 2015 Chris Tessmer <chris.tessmer@onyxpoint.com> - 0.1.0-0
- Initial rollup of lib/ assets from legacy modules simp-common and simp-functions
