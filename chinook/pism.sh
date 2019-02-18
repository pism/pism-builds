#!/bin/bash

set -e
set -u
set -x

optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"

# No. of cores for make
N=8

branch=dev
if [ $# -gt 0 ] ; then  # if user says "pism.sh frontal-melt" then use "frontal-melt" branch
  branch="$1"
fi


build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 --no-single-branch https://github.com/pism/pism.git . || git pull

    git checkout $branch

    rm -rf build
    mkdir -p build
    cd build

    # use Intel's C and C++ compilers
    export CC=mpicc
    export CXX=mpicxx
    cmake -DCMAKE_CXX_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPETSC_EXECUTABLE_RUNS=ON \
	  -DPism_BUILD_PYTHON_BINDINGS=ON \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e
}

build_pism
