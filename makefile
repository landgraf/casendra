BUILDER ?= gprbuild -p -gnat12 -gnata
FLAGS ?=
ifeq (${DEBUG}, True)
	FLAGS +=  -gnata -ggdb -g -gnatVa
else
	DEBUG = False
endif
NAME = $(shell basename ${PWD})
PROJECT ?= casendra
DESTDIR ?= 
prefix ?= /usr/local
libdir ?= ${prefix}/lib
bindir ?= ${prefix}/bin
includedir ?= ${prefix}/include
gprdir ?= ${prefix}/share/gpr
VERSION = 0.1
export LIBRARY_TYPE ?= relocatable

INSTALLER ?=  gprinstall -p --prefix=${prefix} --sources-subdir=${includedir}/${PROJECT} \
							--link-lib-subdir=${libdir} --lib-subdir=${libdir}/${PROJECT}

all: build
debug :clean build_debug
check_syntax: clean build_syntax
warn: clean build_all_warnings
strip: clean build_strip
prof: clean build_prof
.PHONY : install


clean_rpm:
	rm -rf ${HOME}/rpmbuild/SOURCES/${NAME}-${VERSION}.tgz
	rm  -f packaging/${NAME}-build.spec
	find ${HOME}/rpmbuild -name "${NAME}*.rpm" -exec rm -f {} \; 

rpm: clean_rpm
	git archive --prefix=${NAME}-${VERSION}/ -o ${HOME}/rpmbuild/SOURCES/${NAME}-${VERSION}.tar.gz HEAD
	sed "s/@RELEASE@/`date +%s`/;s/@DEBUG@/${DEBUG}/" packaging/Fedora.spec > packaging/${NAME}-build.spec
	rpmbuild -ba packaging/${NAME}-build.spec
	rm -f packaging/${NAME}-build.spec

build_libs:
	${BUILDER} -P gnat/${PROJECT}_libs ${FLAGS} 

build_tools: build_libs
	${BUILDER} -P gnat/${PROJECT}_tools ${FLAGS}
	-cd bin && ln -s casendra_cli csdownloader && ln -s casendra_cli casendrad

build: build_libs build_tools

install:
	${INSTALLER} -P gnat/${PROJECT}_libs
	${INSTALLER} -P gnat/${PROJECT}_tools
	-cd ${bindir} && ln -s casendra_cli csdownloader && ln -s casendra_cli casendrad

clean:
	-gnat clean -P gnat/${PROJECT}_libs
	-gnat clean -P gnat/${PROJECT}_tools
## and control shoot to the head...
	rm -rf bin/ obj/ lib/  tmp/ 

