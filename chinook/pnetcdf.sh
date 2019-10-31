#!/bin/bash

set -x
set -e
set -u

build_pnetcdf() {
    N=8

    version=1.12.0
    prefix=${LOCAL_LIB_DIR}/pnetcdf
    build_dir=${LOCAL_LIB_DIR}/sources/pnetcdf/
    url=https://parallel-netcdf.github.io/Release/pnetcdf-${version}.tar.gz

    mkdir -p ${build_dir}
    pushd ${build_dir}

    wget -nc ${url}
    tar xzf pnetcdf-${version}.tar.gz

    pushd pnetcdf-${version}
    export CFLAGS="-fPIC"

    ./configure --prefix=${prefix} \
                --enable-shared \
                --disable-cxx \
                --disable-fortran 2>&1 | tee pnetcdf_configure.log

    make all -j $N 2>&1 | tee pnetcdf_compile.log
    make install 2>&1 | tee pnetcdf_install.log
    popd
    popd
}

build_pnetcdf
