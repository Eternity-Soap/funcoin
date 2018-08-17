#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

FUNCOIND=${FUNCOIND:-$SRCDIR/funcoind}
FUNCOINCLI=${FUNCOINCLI:-$SRCDIR/funcoin-cli}
FUNCOINTX=${FUNCOINTX:-$SRCDIR/funcoin-tx}
FUNCOINQT=${FUNCOINQT:-$SRCDIR/qt/funcoin-qt}

[ ! -x $FUNCOIND ] && echo "$FUNCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
FUNVER=($($FUNCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$FUNCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $FUNCOIND $FUNCOINCLI $FUNCOINTX $FUNCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${FUNVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${FUNVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
