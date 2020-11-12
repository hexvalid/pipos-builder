#
# pppd makefile for Linux
#

# Default installation locations
DESTDIR = $(INSTROOT)@DESTDIR@
BINDIR = $(DESTDIR)/sbin
INCDIR = $(DESTDIR)/include

TARGETS = pppd

PPPDSRCS = main.c magic.c fsm.c lcp.c ipcp.c upap.c chap-new.c md5.c ccp.c \
	   ecp.c ipxcp.c auth.c options.c sys-linux.c md4.c chap_ms.c \
	   demand.c utils.c tty.c eap.c chap-md5.c session.c

HEADERS = ccp.h session.h chap-new.h ecp.h fsm.h ipcp.h \
	ipxcp.h lcp.h magic.h md5.h patchlevel.h pathnames.h pppd.h \
	upap.h eap.h

PPPDOBJS = main.o magic.o fsm.o lcp.o ipcp.o upap.o chap-new.o md5.o ccp.o \
	   ecp.o auth.o options.o demand.o utils.o sys-linux.o ipxcp.o tty.o \
	   eap.o chap-md5.o session.o

#
# include dependencies if present
ifeq (.depend,$(wildcard .depend))
include .depend
endif

CC = gcc


COPTS = -O2 -pipe -Wall -g
LIBS =

CHAPMS=y
MPPE=y

#FILTER=y
#HAVE_MULTILINK=y
#USE_TDB=y
#HAS_SHADOW=y
#USE_LIBUTIL=y
#USE_PAM=y
#MAXOCTETS=y

INCLUDE_DIRS= -I./include

COMPILE_FLAGS= -DHAVE_PATHS_H -DIPX_CHANGE -DHAVE_MMAP

CFLAGS= $(COPTS) $(COMPILE_FLAGS) $(INCLUDE_DIRS) '-DDESTDIR="@DESTDIR@"'

ifdef CHAPMS
CFLAGS   += -DCHAPMS=1
NEEDDES=y
PPPDOBJS += md4.o chap_ms.o
HEADERS	+= md4.h chap_ms.h
ifdef MSLANMAN
CFLAGS   += -DMSLANMAN=1
endif
ifdef MPPE
CFLAGS   += -DMPPE=1
endif
endif

# EAP SRP-SHA1
ifdef USE_SRP
CFLAGS	+= -DUSE_SRP -DOPENSSL -I/usr/local/ssl/include
LIBS	+= -lsrp -L/usr/local/ssl/lib -lcrypto
TARGETS	+= srp-entry
EXTRAINSTALL = $(INSTALL) -s -c -m 555 srp-entry $(BINDIR)/srp-entry
EXTRACLEAN += srp-entry.o
NEEDDES=y
else
# OpenSSL has an integrated version of SHA-1, and its implementation
# is incompatible with this local SHA-1 implementation.  We must use
# one or the other, not both.
PPPDSRCS += sha1.c
HEADERS += sha1.h
PPPDOBJS += sha1.o
endif

ifdef HAS_SHADOW
CFLAGS   += -DHAS_SHADOW
#LIBS     += -lshadow $(LIBS)
endif

ifneq ($(wildcard $(shell $(CC) --print-sysroot)/usr/include/crypt.h),)
CFLAGS  += -DHAVE_CRYPT_H=1
LIBS	+= -lcrypt
endif

ifdef USE_LIBUTIL
CFLAGS	+= -DHAVE_LOGWTMP=1
LIBS	+= -lutil
endif

ifdef NEEDDES
ifndef USE_CRYPT
CFLAGS   += -I$(shell $(CC) --print-sysroot)/usr/include/openssl
LIBS     += -lcrypto
else
CFLAGS   += -DUSE_CRYPT=1
endif
PPPDOBJS += pppcrypt.o
HEADERS += pppcrypt.h
endif

# For "Pluggable Authentication Modules", see ftp.redhat.com:/pub/pam/.
ifdef USE_PAM
CFLAGS   += -DUSE_PAM
LIBS     += -lpam -ldl
endif

# Multi-linnk
ifdef HAVE_MULTILINK
	# Multilink implies the use of TDB
	USE_TDB=y

	CFLAGS += -DHAVE_MULTILINK
	PPPDSRCS += multilink.c
	PPPDOBJS += multilink.o
endif

# TDB
ifdef USE_TDB
	CFLAGS += -DUSE_TDB=1
	PPPDSRCS += tdb.c spinlock.c
	PPPDOBJS += tdb.o spinlock.o
	HEADERS += tdb.h spinlock.h
endif

# Lock library binary for Linux is included in 'linux' subdirectory.
ifdef LOCKLIB
LIBS     += -llock
CFLAGS   += -DLOCKLIB=1
endif

ifdef SYSTEMD
LIBS += -lsystemd
CFLAGS   += -DSYSTEMD=1
endif

ifdef PLUGIN
CFLAGS	+= -DPLUGIN
LDFLAGS_PLUGIN	+= -Wl,-E
LIBS	+= -ldl
endif

ifdef FILTER
ifneq ($(wildcard /usr/include/pcap-bpf.h),)
LIBS    += -lpcap
CFLAGS  += -DPPP_FILTER
endif
endif

ifdef HAVE_INET6
     PPPDSRCS += ipv6cp.c eui64.c
     HEADERS  += ipv6cp.h eui64.h
     PPPDOBJS += ipv6cp.o eui64.o
     CFLAGS   += -DINET6=1
endif

ifdef CBCP
     PPPDSRCS += cbcp.c
     PPPDOBJS += cbcp.o
     CFLAGS += -DCBCP_SUPPORT
     HEADERS += cbcp.h
endif

ifdef MAXOCTETS
     CFLAGS += -DMAXOCTETS
endif

INSTALL= install

all: $(TARGETS)

install: pppd
	$(EXTRAINSTALL)
	$(INSTALL) -s -c -m 555 pppd $(BINDIR)/pppd
	if chgrp pppusers $(BINDIR)/pppd 2>/dev/null; then \
	  chmod o-rx,u+s $(BINDIR)/pppd; fi

pppd: $(PPPDOBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(LDFLAGS_PLUGIN) -o pppd $(PPPDOBJS) $(LIBS)

srp-entry:	srp-entry.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ srp-entry.c $(LIBS)

install-devel:
	mkdir -p $(INCDIR)/pppd
	$(INSTALL) -c -m 644 $(HEADERS) $(INCDIR)/pppd

clean:
	rm -f $(PPPDOBJS) $(EXTRACLEAN) $(TARGETS) *~ #* core

depend:
	$(CPP) -M $(CFLAGS) $(PPPDSRCS) >.depend
