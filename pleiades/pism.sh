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

branch=dev
if [ $# -gt 0 ] ; then  # if user says "pism.sh frontal-melt" then use "frontal-melt" branch
  branch="$1"
fi

# MPI_ROOT is set by the module system
MPI_INCLUDE="${MPI_ROOT}/include"
MPI_LIBRARY="${MPI_ROOT}/lib/libmpi.so"

build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 --no-single-branch https://github.com/pism/pism.git . || git pull

    git checkout $branch

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    export CC=icc
    export CXX=icpc
    export HDF5_ROOT=${LOCAL_LIB_DIR}/hdf5
    opt_flags="-O3 -ipo -axCORE-AVX2 -xSSE4.2 -fp-model precise"
    cmake -DMPI_C_INCLUDE_PATH=$MPI_INCLUDE \
          -DMPI_C_LIBRARIES=$MPI_LIBRARY \
          -DPETSC_EXECUTABLE_RUNS=YES \
          -DCMAKE_CXX_FLAGS="-std=c++11 ${opt_flags} -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="-std=c11 ${opt_flags} -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR;$LOCAL_LIB_DIR/hdf5;$LOCAL_LIB_DIR/netcdf" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j4 install
}

build_pism

