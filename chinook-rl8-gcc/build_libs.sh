#!/bin/bash

set -x
set -u
set -e

# Build prerequisite libraries

# Run as "SET_ENV=1 ./build_libs.sh" to set environment variables
# needed to build PISM *without* actually re-building libraries.
if [ -v SET_ENV ]; then
    SET_ENV=true
else
    SET_ENV=false
fi

SET_ENV=false

export LOCAL=$LOCAL_LIB_DIR
export BUILD=$LOCAL_LIB_DIR/build/

# Build most dependencies using GCC
export CC=gcc
export CXX=g++
export MPICC=mpicc
export MPICXX=mpicxx


export prefix=$LOCAL/hdf5
export build_dir=$BUILD
# ${SET_ENV} || ./hdf5.sh | tee hdf5.log
export hdf5_prefix=$LOCAL/hdf5

export prefix=$LOCAL/netcdf
export build_dir=$BUILD
# ${SET_ENV} || ./netcdf.sh | tee netcdf.log
export netcdf_prefix=$LOCAL/netcdf

export prefix=$LOCAL/udunits2
export build_dir=$BUILD
# ${SET_ENV} || ./udunits2.sh | tee udunits2.log
export udunits2_prefix=$LOCAL/udunits2


export prefix=$LOCAL/petsc
export build_dir=$BUILD
# ${SET_ENV} || ./petsc.sh | tee petsc.log
export PETSC_DIR=$LOCAL/petsc

./pism.sh
