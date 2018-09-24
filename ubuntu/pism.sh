#!/bin/bash

branch=${1}

prefix=${HOME}/local/
PISM_DIR=${HOME}/pism
N=4


build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    rm -rf build
    mkdir -p build
    cd build

    export PETSC_DIR=~/local/petsc/petsc-3.10.0/
    export PETSC_ARCH=opt-32bit

    CC=mpicc CXX=mpicxx cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_FIND_ROOT_PATH="${prefix}/hdf5;${prefix}/netcdf;${prefix}/pnetcdf" \
        -DCMAKE_INSTALL_PREFIX=${PISM_DIR} \
        -DPism_LOOK_FOR_LIBRARIES=YES \
        -DPism_USE_PROJ4=YES \
        ${PISM_DIR}/sources

    make -j $N install    
    set +x
    set +e
    
}

build_pism
