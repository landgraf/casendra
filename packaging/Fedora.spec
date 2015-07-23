Name:            casendra
Version:	 0.2
Release:	 3%{?dist}
Summary:	 Library and set of tools to work with strata

Group:	         Applications/Engineering
License:	 GPLv3+
URL:		 https://github.com/landgraf/casendra
Source0:	 %{name}-%{version}.tar.gz

BuildRequires:	gcc-gnat aws-devel > 3.2
BuildRequires:  gnatcoll-devel >= 2014 
BuildRequires:  gprbuild
BuildRequires:  fedora-gnat-project-common > 3
Requires:       %{name}-libs

%description
%{summary}

%prep
%setup -q

%package libs
Summary: libraries for %{name}
License: GPLv3+

%description libs
%{summary}

%package devel
Summary: Devel files for %{name}
License: GPLv3+

%description devel
%{summary}

%build
DEBUG=True make %{?_smp_mflags} BUILDER="gprbuild -p %{GPRbuild_optflags}"

%check
export LD_LIBRARY_PATH="%{buildroot}/%{_libdir}/:$LD_LIBRARY_PATH"
make check

%install
%make_install prefix=%{buildroot}/%{_prefix} libdir=%{buildroot}/%{_libdir}
cd %{buildroot}/%{_libdir} && ln -s %{name}/lib%{name}.so.%{version} .

%post     -p /sbin/ldconfig

%postun   -p /sbin/ldconfig


%files
%doc %{name}.conf.templ
%{_bindir}/%{name}_cli
%{_bindir}/%{name}d
%{_bindir}/csdownloader
%{_bindir}/csclean

%files devel
%{_libdir}/%{name}/*.ali
%{_includedir}/%{name}
%{_libdir}/lib%{name}.so
%{_libdir}/%{name}/lib%{name}.so
%_GNAT_project_dir/manifests
%_GNAT_project_dir/%{name}*gpr

%files libs
%{_libdir}/lib%{name}.so.%{version}
%{_libdir}/%{name}/lib%{name}.so.%{version}


%changelog
* Thu Jun 23 2015 Pavel Zhukov <pzhukov@redhat.com> - 0.2-1
- New release (0.2)

* Wed Jun  3 2015 Pavel Zhukov <pzhukov@redhat,com> - 0.1-3
- Package template

* Tue Jun 02 2015 Pavel Zhukov <pzhukov@redhat.com> - 0.1-2
- Initial build

