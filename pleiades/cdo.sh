#!/bin/bash

set -x
set -e
set -u

N=8

# requires zlib and proj.4
build_cdo() {

    # ./zlib.sh
    # ./proj4.sh

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc --no-check-certificate https://code.mpimet.mpg.de/attachments/20826/cdo-1.9.8.tar.gz 
    tar -zxvf cdo-1.8.2.tar.gz
    cd cdo-1.9.8

    export CC=icc
    export LIBS="-lmpi"
    ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-netcdf=/nasa/netcdf/4.4.1.1_mpt \
	--with-hdf5=/nasa/hdf5/1.8.18_mpt \
	--with-zlib=$LOCAL_LIB_DIR \
	--with-proj=$LOCAL_LIB_DIR 2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_cdo
