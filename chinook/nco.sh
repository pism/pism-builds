#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco
    git checkout 4.6.5

    export CC=mpicc
    export CPPFLAGS=-I$LOCAL_LIB_DIR/netcdf/include
    opt="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"
    #export LIBS="-liomp5 -lpthread"
    export LDFLAGS="-L$LOCAL_LIB_DIR/netcdf/lib -L/usr/lib64"
    ./configure \
	--prefix=$LOCAL_LIB_DIR \
	--enable-netcdf-4 \
	--enable-udunits2 \
	--enable-openmp 2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log
}

build_nco
