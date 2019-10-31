#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_hdf5() {
    # download and build HDF5
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    prefix=$LOCAL_LIB_DIR/hdf5
    version=1.10.5

    url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/src/hdf5-${version}.tar.gz

    wget -nc ${url}
    tar xzvf hdf5-${version}.tar.gz

    cd hdf5-${version}
    CC=mpicc ./configure --enable-parallel --prefix=${prefix} 2>&1 | tee hdf5_configure.log

    make all -j $N 2>&1 | tee hdf5_compile.log
    make install 2>&1 | tee hdf5_install.log
}

build_hdf5
