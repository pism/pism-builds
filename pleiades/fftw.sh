#!/bin/bash

set -e
set -u
set -x

# Install fftw in  /opt/fftw,
# using /var/tmp/build/fftw as the build directory.

MPICC=${MPICC:-mpicc}

prefix=${prefix:-/opt/fftw}
build_dir=${build_dir:-/var/tmp/build/fftw}

mkdir -p $LOCAL/fftw

mkdir -p ${build_dir}
cd ${build_dir}

build_fftw() {

    # download and build FFTW
    mkdir -p $LOCAL_LIB_DIR
    cd $LOCAL_LIB_DIR

    version=3.3.10
    url=ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz

    wget -nc ${url}
    tar xzvf fftw-${version}.tar.gz

    cd fftw-${version}

    ./configure \
      --prefix=${prefix} \
      --with-pic \
      --enable-mpi \
      CC="$CC" MPICC="$MPICC" 2>&1 | tee fftw_configure.log

    make -j 1 2>&1 | tee fftw_compile.log
    make install 2>&1 | tee fftw_install.log

}

build_fftw
