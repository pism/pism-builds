#!/bin/bash

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=8

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

# stop on error
set -e
# print commands before executing them
set -x

build_hdf5() {
    # download and build HDF5

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.16.tar.gz
    tar -xvf hdf5-1.8.16.tar.gz

    cd hdf5-1.8.16
    CC=mpicc ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR

    make all -j $N
    make install
}

build_netcdf() {
    # download and build netcdf

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.0.tar.gz
    tar -zxvf netcdf-4.4.0.tar.gz

    cd netcdf-4.4.0
    CC=mpicc CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib ./configure \
        --enable-netcdf4 \
        --disable-dap \
        --prefix=$LOCAL_LIB_DIR 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}

build_petsc () {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .

    OPTS='--with-fc=0 --with-64-bit-indices=1 --with-error-checking=1 --with-debugging=0'

    ./configure CC=mpicc CXX=mpicxx $OPTS

    make all
}

build_pism () {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    cmake -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR" \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j $N install
}

build_petsc

build_hdf5

build_netcdf

build_pism
