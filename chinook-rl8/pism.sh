#!/bin/bash

set -e
set -u
set -x

optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -fp-model precise"

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

    git clone  --no-single-branch https://github.com/pism/pism.git . || git pull

    git checkout $branch

    rm -rf build
    mkdir -p build
    cd build

    # use Intel's C and C++ compilers
    export CC=mpiicc
    export CXX=mpiicpc
    # Silence OpenMPI's error message about a part of its system that is not available on login nodes
    export OMPI_MCA_plm_rsh_agent=""
    # EBROOTNETCDF below is set by the module system
    cmake -DCMAKE_CXX_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006" \
	  -DNETCDF_ROOT=${EBROOTNETCDF} \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
	  -DPism_BUILD_PYTHON_BINDINGS=OFF \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ=YES \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e
}

build_pism
