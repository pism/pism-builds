#!/bin/bash


prefix=${HOME}/local/
N=4

branch=${1}
dbg=$2

PISM_DIR=${HOME}/local/pism
BUILD_DIR=build-${dbg}

build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b ${branch} https://github.com/pism/pism.git . || git pull

    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    export PETSC_DIR=~/local/petsc/petsc-3.10.0/
    
    export PETSC_ARCH=${dbg}-32bit

    if [ "$dbg" = "dbg" ]; then
        export BUILD_TYPE=Debug
    else
        export BUILD_TYPE=Release
    fi

    CC=mpicc CXX=mpicxx cmake \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DCMAKE_INSTALL_PREFIX=${PISM_DIR} \
        -DPism_LOOK_FOR_LIBRARIES=YES \
        -DPism_BUILD_DOCS=YES \
        -DPism_BUILD_PYTHON_BINDINGS=NO \
        -DPism_USE_PROJ4=YES \
        ${PISM_DIR}/sources

    make -j $N install    
    set +x
    set +e
    
}

build_pism $1 $2
