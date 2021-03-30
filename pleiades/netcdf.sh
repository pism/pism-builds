#!/bin/bash

set -x
set -e
set -u

N=8

build_netcdf() {
    
    version=4.7.4
    prefix=${LOCAL_LIB_DIR}/netcdf
    build_dir=${LOCAL_LIB_DIR}/sources/netcdf
    url=ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-${version}.tar.gz

    mkdir -p ${build_dir}
    pushd ${build_dir}

    wget -nc ${url}
    tar zxf netcdf-c-${version}.tar.gz

    pushd netcdf-c-${version}
    export CFLAGS='-g'
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5/lib
    export CC=mpicc

   ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
    make check 2>&1 | tee netcdf_check.log
    popd
    popd
}

build_netcdf
