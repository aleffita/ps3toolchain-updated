#!/bin/sh -e
# binutils-PPU.sh by Naomi Peori (naomi@peori.ca)

BINUTILS="binutils-2.42"

if [ ! -d ${BINUTILS} ]; then

  ## Download the source code.
  if [ ! -f ${BINUTILS}.tar.bz2 ]; then wget --continue https://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2; fi

  ## Download an up-to-date config.guess and config.sub
  if [ ! -f config.guess ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
  if [ ! -f config.sub ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

  ## Unpack the source code.
  tar xfvj ${BINUTILS}.tar.bz2

  ## Patch the source code.
  cat ../patches/${BINUTILS}-PS3-PPU.patch | patch -p1 -d ${BINUTILS}

  ## Replace config.guess and config.sub
  cp config.guess config.sub ${BINUTILS}

fi

if [ ! -d ${BINUTILS}/build-ppu ]; then

  ## Create the build directory.
  mkdir ${BINUTILS}/build-ppu

fi

## Enter the build directory.
cd ${BINUTILS}/build-ppu

## Configure the build.
unset LDFLAGS
../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
		--with-gcc \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-64-bit-bfd \
		--enable-lto \
		--disable-nls \
		--disable-shared \
		--disable-debug \
		--disable-dependency-tracking \
		--disable-werror

## Compile and install.
PROCS="$(nproc --all 2>&1)" || ret=$?
if [ ! -z $ret ]; then PROCS=12; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} libdir=`pwd`/host-libs/lib install
