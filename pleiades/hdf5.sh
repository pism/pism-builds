#!/bin/bash

set -e
set -x
set -u

N=8

build_hdf5() {
    # download and build HDF5 
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    rm -rf hdf5
    git clone -b hdf5_1_8_18 --depth 1 https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git
    cd hdf5

    CC=mpicc ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR/hdf5 2>&1 | tee hdf5_configure.log

    make all -j $N 2>&1 | tee hdf5_compile.log
    make install 2>&1 | tee hdf5_install.log
}

build_hdf5
