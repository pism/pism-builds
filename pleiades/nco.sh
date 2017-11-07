#!/bin/bash

set -x
set -e
set -u

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# No. of cores for make
N=8

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco
    git checkout 4.6.7

    export NETCDF_ROOT=/nasa/netcdf/4.4.1.1_mpt
    export ANTLR_ROOT=/nasa/sles11/nco/4.6.2/gcc/mpt
    export UDUNITS2_PATH=$LOCAL_LIB_DIR
    ./configure \
	--prefix=$LOCAL_LIB_DIR \
	--enable-netcdf-4 \
	--enable-udunits2 \
	--enable-openmp 2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log
}
