#!/bin/bash -e
# gcc-newlib-PPU.sh by Naomi Peori (naomi@peori.ca)

GCC="gcc-13.2.0"
NEWLIB="newlib-4.4.0.20231231"

if [ ! -d ${GCC} ]; then

  ## Download the source code.
  if [ ! -f gcc-13.2-darwin-r2.tar.gz ]; then wget -L --continue https://github.com/aleffita/gcc-13-branch/archive/refs/tags/gcc-13.2-darwin-r2.tar.gz; fi
  if [ ! -f ${NEWLIB}.tar.gz ]; then wget -L --continue https://sourceware.org/pub/newlib/${NEWLIB}.tar.gz; fi

  ## Unpack the source code.  
  rm -Rf ${GCC} && tar xfvz gcc-13.2-darwin-r2.tar.gz
  mv gcc-13-branch-gcc-13.2-darwin-r2 ${GCC}
  file ${NEWLIB}.tar.gz
  rm -Rf ${NEWLIB} && tar xfvz ${NEWLIB}.tar.gz

  ## Patch the source code.
  #cat ../patches/gcc-13.2.0-PS3-PPU.patch | patch -p1 -d gcc-13.2.0

  cat ../patches/${GCC}-PS3-PPU.patch | patch -p1 -d ${GCC}
  cat ../patches/${NEWLIB}-PS3-PPU.patch | patch -p1 -d ${NEWLIB}

  ## Enter the source code directory.
  cd ${GCC}

  ## Create the newlib symlinks.
  ln -s ../${NEWLIB}/newlib newlib
  ln -s ../${NEWLIB}/libgloss libgloss

  ## Download the prerequisites.
  ./contrib/download_prerequisites

  ## Leave the source code directory.
  cd ..

fi

if [ ! -d ${GCC}/build-ppu ]; then

  ## Create the build directory.
  mkdir ${GCC}/build-ppu

fi

## Enter the build directory.
cd ${GCC}/build-ppu

# Avoid breakage
CFLAGS="-Werror=format-security -Wno-error=deprecated-declarations -Wno-error=int-conversion -Wno-mismatched-tags"
CXXFLAGS="-Werror=format-security -Wno-error=deprecated-declarations -Wno-error=int-conversion -Wno-mismatched-tags"
../configure --prefix="$TOOLCHAIN_DIR" --target="powerpc64-ps3-elf" \
  --with-cpu="cell" \
  --with-newlib \
  --with-system-zlib \
  --enable-languages="c,c++" \
  --enable-long-double-128 \
  --enable-lto \
  --enable-threads \
  --enable-newlib-multithread \
  --enable-newlib-hw-fp \
  --disable-dependency-tracking \
  --disable-libcc1 \
  --disable-libstdcxx-pch \
  --disable-shared \
  --disable-win32-registry \
  --disable-multilib \
  --without-headers \
  --disable-nls \
  --disable-werror

  
PROCS="$(nproc --all 2>&1)" || ret=$?
if [ ! -z $ret ]; then PROCS=8; fi
${MAKE:-make} -j$PROCS all 

# Verifica se a arquitetura atual é a mesma do target
${MAKE:-make} install
