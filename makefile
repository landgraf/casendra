BUILDER ?= gprbuild -p -gnat12 -gnata
FLAGS ?=
ifeq (${DEBUG}, True)
	FLAGS +=  -gnata -ggdb -g -f -gnatVa
else
	DEBUG = False
endif
NAME = $(shell basename ${PWD})
PROJECT ?= ${NAME}
DESTDIR ?= 
prefix ?= /usr/local
libdir ?= ${prefix}/lib
bindir ?= ${prefix}/bin
includedir ?= ${prefix}/include
gprdir ?= ${prefix}/share/gpr
VERSION = 0.1
export LIBRARY_TYPE ?= relocatable


all: build
debug :clean build_debug
check_syntax: clean build_syntax
warn: clean build_all_warnings
strip: clean build_strip
prof: clean build_prof
.PHONY : install



build_libs:
	${BUILDER} -P gnat/${PROJECT}_libs_build  ${FLAGS} -XAWS_BUILD=relocatable

build_tools: build_libs
	${BUILDER} -P gnat/${PROJECT}_tools_build  ${FLAGS}
	-cd bin && ln -s casendra_cli csdownloader && ln -s casendra_cli casendrad

build: build_libs build_tools

clean:
	-gnat clean -P gnat/${PROJECT}_libs_build
	-gnat clean -P gnat/${PROJECT}_tools_build
## and control shoot to the head...
	rm -rf bin/ obj/ lib/  tmp/ 

