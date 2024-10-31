#!/bin/sh -e
# binutils-SPU.sh by Naomi Peori (naomi@peori.ca)

BINUTILS="binutils-2.22"

if [ ! -d ${BINUTILS} ]; then

  ## Download the source code.
  if [ ! -f ${BINUTILS}.tar.bz2 ]; then wget --continue https://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2; fi

  ## Download an up-to-date config.guess and config.sub
  if [ ! -f config.guess ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
  if [ ! -f config.sub ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

  ## Unpack the source code.
  tar xfvj ${BINUTILS}.tar.bz2

  ## Patch the source code.
  cat ../patches/${BINUTILS}-PS3-SPU.patch | patch -p1 -d ${BINUTILS}

  ## Replace config.guess and config.sub
  cp config.guess config.sub ${BINUTILS}

fi

if [ ! -d ${BINUTILS}/build-spu ]; then

  ## Create the build directory.
  mkdir ${BINUTILS}/build-spu

fi

## Enter the build directory.
cd ${BINUTILS}/build-spu

../configure --prefix="$PS3DEV/spu" --target="spu" \
  --disable-nls \
  --disable-shared \
  --disable-debug \
  --disable-dependency-tracking \
  --disable-werror \
  --with-gcc \
  --with-gnu-as \
  --with-gnu-ld \
  --enable-lto \
  --without-headers

PROCS="$(nproc --all 2>&1)" || ret=$?
if [ ! -z $ret ]; then PROCS=8; fi
${MAKE:-make} -j$PROCS all 

# Verifica se a arquitetura atual é a mesma do target
${MAKE:-make} libdir=`pwd`/host-libs/lib install

