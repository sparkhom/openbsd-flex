#       from: @(#)Makefile      5.4 (Berkeley) 6/24/90
#       $NetBSD: Makefile,v 1.9 2011/03/08 19:25:32 plunky Exp $
#
# By default, flex will be configured to generate 8-bit scanners only if the
# -8 flag is given.  If you want it to always generate 8-bit scanners, add
# "-DDEFAULT_CSIZE=256" to CPPFLAGS.  Note that doing so will double the size
# of all uncompressed scanners.
#
# If on your system you have trouble building flex due to 8-bit character
# problems, remove the -8 from FLEX_FLAGS and the "#define FLEX_8_BIT_CHARS"
# from the beginning of flexdef.h.
#
# To bootstrap lex, cp initscan.c to scan.c and run make.

PROG=   lex
CPPFLAGS+=-I. -I${.CURDIR} -DHAVE_CONFIG_H
SRCS= buf.c ccl.c dfa.c ecs.c filter.c gen.c main.c misc.c \
	  nfa.c options.c parse.y regex.c scan.l scanflags.c \
	  scanopt.c skel.c sym.c tables.c tables_shared.c \
	  tblcmp.c yylex.c

CLEANFILES+=skel.c parse.h
INCS    =FlexLexer.h
INCSDIR=/usr/include/g++
LDADD+=-lm

MAN = flex.1

LINKS=  ${BINDIR}/lex ${BINDIR}/flex \
		${BINDIR}/lex ${BINDIR}/flex++
MLINKS= flex.1 lex.1

# Our yacc is too old to compile parse.y; use bootstrapped parse.c instead
parse.c: parse.y
	cp ${.CURDIR}/initparse.c parse.c;
	cp ${.CURDIR}/initparse.h parse.h

skel.c: flex.skl mkskel.sh flexint.h tables_shared.h
	sed -e 's/m4_/m4postproc_/g' -e 's/m4preproc_/m4_/g' \
		${.CURDIR}/flex.skl | m4 -I${.CURDIR} -P \
		-DFLEX_MAJOR_VERSION=`echo ${VERSION} | cut -f 1 -d .` \
		-DFLEX_MINOR_VERSION=`echo ${VERSION} | cut -f 2 -d .` \
		-DFLEX_SUBMINOR_VERSION=`echo ${VERSION} | cut -f 3 -d .` | \
		sed -e 's/m4postproc_/m4_/g' | \
		sh ${.CURDIR}/mkskel.sh  > ${.TARGET}

.include <bsd.prog.mk>
