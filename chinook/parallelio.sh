#!/bin/bash

set -x
set -e
set -u

build_parallelio() {

    netcdf_prefix=${LOCAL_LIB_DIR}/netcdf
    pnetcdf_prefix=${LOCAL_LIB_DIR}/pnetcdf

    url=https://github.com/NCAR/ParallelIO.git
    build=${LOCAL_LIB_DIR}/sources/parallelio
    prefix=${LOCAL_LIB_DIR}/parallelio

    rm -rf ${build}
    mkdir -p ${build}/sources ${build}/build

    git clone --depth=1 -b master ${url} ${build}/sources

    pushd ${build}/build

    export CC=mpicc

    cmake \
	-DCMAKE_C_FLAGS="-fPIC" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=${prefix} \
	-DNetCDF_PATH=${netcdf_prefix} \
	-DPnetCDF_PATH=${pnetcdf_prefix} \
	-DPIO_ENABLE_FORTRAN=0 \
	-DPIO_ENABLE_TIMING=0 \
	${build}/sources

    make -j4 install

    popd
}

build_parallelio
