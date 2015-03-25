BUILDER ?= gprbuild -p -gnat12 -gnata
FLAGS ?=
ifeq (${DEBUG}, True)
	FLAGS +=  -gnata -ggdb -g -f
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


all: build
debug :clean build_debug
check_syntax: clean build_syntax
warn: clean build_all_warnings
strip: clean build_strip
prof: clean build_prof
.PHONY : install

build:
	${BUILDER} -p -P gnat/${PROJECT} ${FLAGS}

clean:
	gnat clean -P gnat/${PROJECT}
	## and control shoot to the head...
	rm -rf bin/ obj/ lib/  tmp/ 

