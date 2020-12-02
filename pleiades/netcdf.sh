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
    export CC=mpicc
    export CXX=mpicxx
    export FC=mpif90 
    export CPPFLAGS="-I/nasa/hdf5/1.12.0_mpt/include"
    export LDFLAGS="-L/nasa/hdf5/1.12.0_mpt/lib"
    ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log

    popd
    popd
}

build_netcdf
