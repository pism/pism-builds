#!/bin/bash

set -x
set -e

prefix=${HOME}/local/
N=4

build_pnetcdf() {
    build_dir=${prefix}/build/pnetcdf/
    mkdir -p ${build_dir}
    version=1.12.0

    pushd ${build_dir}
    wget -nc https://parallel-netcdf.github.io/Release/pnetcdf-${version}.tar.gz
    tar xzf pnetcdf-${version}.tar.gz

    pushd pnetcdf-${version}
    export CFLAGS="-fPIC"

    ./configure --prefix=${prefix}/pnetcdf \
                --enable-shared \
                --disable-cxx \
                --disable-fortran 2>&1 | tee pnetcdf_configure.log

    make all -j $N 2>&1 | tee pnetcdf_compile.log
    make install 2>&1 | tee pnetcdf_install.log
    popd
    popd
}

build_pnetcdf
