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

    # We use 1.8.15 because newer version seg fault with Intel 2016 Compilers
    name=hdf5-1.8.15
    url=https://support.hdfgroup.org/ftp/HDF5/releases/${name}/src/${name}.tar.gz

    wget -nc ${url}
    tar xzvf ${name}.tar.gz

    cd ${name}
    CC=mpicc ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR/hdf5 2>&1 | tee hdf5_configure.log

    make all -j $N 2>&1 | tee hdf5_compile.log
    make install 2>&1 | tee hdf5_install.log
}

build_hdf5
