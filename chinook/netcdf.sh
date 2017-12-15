#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_netcdf() {
    # download and build netcdf

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    version=4.4.1.1
    url=ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-${version}.tar.gz

    wget -nc ${url}
    tar -zxvf netcdf-${version}.tar.gz

    cd netcdf-${version}
    export CC=$LOCAL_LIB_DIR/hdf5/bin/h5pcc
    export CC=mpicc
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5/lib
    ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}

build_netcdf
