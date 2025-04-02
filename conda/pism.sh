#!/bin/bash

set -e
set -u
set -x

optimization_flags="-O3   -mcpu=apple-m2 -mtune=apple-m2"
optimization_flags="-O3"

# No. of cores for make
N=8

# the default branch is "dev"
branch=dev
if [ $# -gt 0 ] ; then  # if user says "pism.sh frontal-melt" then use "frontal-melt" branch
  branch="$1"
fi

# the default directory is "pism-conda"
PISM_DIR=$HOME/pism
if [ $# -gt 1 ] ; then  # if user says "pism.sh frontal-melt" then use "frontal-melt" branch
  PISM_DIR="$2"
fi


build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --no-single-branch git@github.com:/pism/pism.git . || git pull

    git checkout $branch

    rm -rf build
    mkdir -p build
    cd build

    export CC=mpicc
    export CXX=mpicxx
    cmake -DCMAKE_CXX_FLAGS="${optimization_flags}" \
          -DCMAKE_C_FLAGS="${optimization_flags}" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_DEBUG=YES \
          -DPism_BUILD_PYTHON_BINDINGS=ON \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_YAC_INTERPOLATION=YES \
          -DPism_PKG_CONFIG_STATIC=OFF \
          -DPism_USE_PARALLEL_NETCDF4=NO \
          -DPism_USE_PROJ=YES \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e
}

build_pism
