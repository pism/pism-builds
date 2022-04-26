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

export LOCAL=$HOME/local/
export BUILD=$HOME/local/build/

# Build most dependencies using GCC
export CC=gcc
export CXX=g++
export MPICC="mpicc -cc=$CC"
export MPICXX="mpicxx -cxx=$CXX"

export prefix=$LOCAL/hdf5
export build_dir=$BUILD
${SET_ENV} || ./hdf5.sh | tee hdf5.log
export hdf5_prefix=$LOCAL/hdf5

export prefix=$LOCAL/netcdf
export build_dir=$BUILD
${SET_ENV} || ./netcdf.sh | tee netcdf.log
export netcdf_prefix=$LOCAL/netcdf

export prefix=$LOCAL/udunits2
export build_dir=$BUILD
${SET_ENV} || ./udunits2.sh | tee udunits2.log
export udunits_prefix=$LOCAL/udunits2

export prefix=$LOCAL/proj
export build_dir=$BUILD
${SET_ENV} || ./proj.sh | tee proj.log
export proj_prefix=$LOCAL/proj

# Build PETSc using Intel's icc
export CC=icc
# Note: icc can compile both C and C++ code
export CXX=icc
export MPICC="mpicc -cc=${CC}"
export MPICXX="mpicxx -cxx=${CXX}"
# Support all CPUs on Pleiades and select an optimized version at runtime:
export opt_flags="-axCORE-AVX512,CORE-AVX2 -xAVX -fp-model precise -diag-disable=cpu-dispatch"

export prefix=$LOCAL/petsc
export build_dir=$BUILD
${SET_ENV} || ./petsc.sh | tee petsc.log
export PETSC_DIR=$LOCAL/petsc
