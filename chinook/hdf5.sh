#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_hdf5() {
    # download and build HDF5

    version=1.10.5
    prefix=$LOCAL_LIB_DIR/hdf5
    build_dir=${LOCAL_LIB_DIR}/sources/hdf5
    url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/src/hdf5-${version}.tar.gz

    mkdir -p ${build_dir}
    pushd ${build_dir}

    wget -nc ${url}
    tar xzf hdf5-${version}.tar.gz

    pushd hdf5-${version}
    export CC=mpicc

    ./configure --enable-parallel --prefix=${prefix} 2>&1 | tee hdf5_configure.log

    make all -j $N 2>&1 | tee hdf5_compile.log
    make install 2>&1 | tee hdf5_install.log

    popd
    popd
}

build_hdf5
