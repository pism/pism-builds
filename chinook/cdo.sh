#!/bin/bash

set -u
set -e
set -x

# No. of cores for make
N=8

build_cdo(){

    version=1.9.5

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc https://code.mpimet.mpg.de/attachments/download/18264/cdo-${version}.tar.gz
    tar -zxvf cdo-${version}.tar.gz
    cd cdo-${version}

    CC=mpicc ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-hdf5=/usr/local/pkg/data/HDF5/1.8.15-pic-intel-2016b \
	--with-netcdf=/usr/local/pkg/data/netCDF/4.4.1.1-pic-intel-2016b \
        --with-proj=/usr/local/pkg/lib/PROJ/4.9.2-pic-intel-2016b \
        --with-udunits2=/usr/local/pkg/phys/UDUNITS/2.2.20-pic-intel-2016b \
        2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_cdo
