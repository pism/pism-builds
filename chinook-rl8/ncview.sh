#!/bin/bash
# Automate building PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - edit LOCAL_LIB_DIR and PISM_DIR below
# - run scripts building PISM's prerequisite libraries (HDF5, NetCDF, FFTW3, PROJ.4, UDUNITS2)
# - run this script

# stop on error
set -e
# print commands before executing them
set -x
# stop if an environment variable is not defined
set -u

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=8



build_ncview(){

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.7.tar.gz
    tar -zxvf ncview-2.1.7.tar.gz
    cd ncview-2.1.7

    ./configure --prefix=${LOCAL_LIB_DIR} \
	--with-nc-config=/usr/local/pkg/MPI/intel/2022.1.0/impi/2021.6.0/netCDF/4.9.0/bin//nc-config \
	 2>&1 | tee ncview_configure.log

    make -j $N 2>&1 | tee ncview_compile.log
    make install 2>&1 | tee ncview_install.log
}


build_ncview

