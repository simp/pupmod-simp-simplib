Summary: A collection of common SIMP functions, facts, and puppet code
Name: pupmod-simplib
Version: 1.0.0
Release: 0
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppetlabs-stdlib
Requires: puppet >= 3.3.0
Buildarch: noarch
Obsoletes: pupmod-common
Obsoletes: pupmod-functions

Prefix: /etc/puppet/environments/simp/modules

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
* Fri Nov 13 2015 Chris Tessmer <chris.tessmer@onyxpoint.com> - 1.0.0-0
- Imported manifests/ template/ and files/ assets from pupmod-common
- manifests/ assets from pupmod-functions are deprecated and will not be imported
- All tests pass; first version is rolled up

* Tue Oct 13 2015 Chris Tessmer <chris.tessmer@onyxpoint.com> - 0.1.0-0
- Initial rollup of lib/ assets from legacy modules simp-common and simp-functions
