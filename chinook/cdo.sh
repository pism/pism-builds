#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_cdo(){

    version=1.9.10

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc https://code.mpimet.mpg.de/attachments/24638/cdo-${version}.tar.gz
    tar -zxvf cdo-${version}.tar.gz
    cd cdo-${version}

    CC=mpicc CXX=mpicxx ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-hdf5=/usr/local/pkg/data/HDF5/1.10.6-pic-intel-2019b \
	--with-netcdf=/usr/local/pkg/data/netCDF/4.7.4-pic-intel-2019b \
        --with-proj=/usr/local/pkg/lib/PROJ/6.1.1-pic-intel-2019b \
        --with-udunits2=/usr/local/pkg/phys/UDUNITS/2.2.26-pic-intel-2019b \
        2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_cdo
