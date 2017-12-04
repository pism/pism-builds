#!/bin/bash

set -x
set -e
set -u

N=8

build_netcdf() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    version=4.5.0
    url=ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-${version}.tar.gz

    wget -nc ${url}
    tar -zxvf netcdf-${version}.tar.gz

    cd netcdf-${version}

    export CFLAGS='-g'
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5/lib
    export CC=mpicc

   ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --disable-v2 \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}

build_netcdf
