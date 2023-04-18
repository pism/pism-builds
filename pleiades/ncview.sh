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

    build_png

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.7.tar.gz
    tar -zxvf ncview-2.1.7.tar.gz
    cd ncview-2.1.7

    CC=mpicc CFLAGS='-g' CPPFLAGS="-I$LOCAL_LIB_DIR/include -I$LOCAL_LIB_DIR/netcdf/include" LDFLAGS="-L$LOCAL_LIB_DIR/lib -L$LOCAL_LIB_DIR/netcdf/lib" ./configure \
	--prefix=${LOCAL_LIB_DIR} \
	--with-nc-config=${LOCAL_LIB_DIR}/netcdf/bin/nc-config \
	--with-png_incdir=${LOCAL_LIB_DIR}/include \
	--with-png_libdir=${LOCAL_LIB_DIR}/lib 2>&1 | tee ncview_configure.log

    make -j $N 2>&1 | tee ncview_compile.log
    make install 2>&1 | tee ncview_install.log
}

build_png() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    git clone --depth 1 --single-branch --branch v1.6.39 https://github.com/glennrp/libpng.git 
    cd libpng
 
    CC=mpicc ./configure \
        --prefix=${LOCAL_LIB_DIR}  2>&1 | tee png_configure.log

    make -j $N 2>&1 | tee png_compile.log
    make install 2>&1 | tee png_install.log

}


build_ncview

