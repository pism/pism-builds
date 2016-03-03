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

build_petsc () {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .

    OPTS='--with-fc=0 --with-64-bit-indices=1 --with-error-checking=1 --with-debugging=0'

    ./configure CC=mpicc CXX=mpicxx $OPTS

    make all
}

build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    cmake -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DCMAKE_FIND_ROOT_PATH=$LOCAL_LIB_DIR \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR;$HDF5PARALLEL_ROOT;$NETCDF_ROOT" \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j $N install
}

build_petsc
build_pism
