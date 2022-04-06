#!/bin/bash

# Build prerequisite libraries, PETSc, and PISM

LOCAL=$HOME/local/
BUILD=$HOME/local/build/

# Build dependencies using GCC
export CC=gcc
export CXX=g++
export MPICC="mpicc -cc=$CC"
export MPICXX="mpicxx -cxx=$CXX"

prefix=$LOCAL/hdf5 build_dir=$BUILD ./hdf5.sh | tee hdf5.log
export hdf5_prefix=$LOCAL/hdf5

prefix=$LOCAL/netcdf build_dir=$BUILD ./netcdf.sh | tee netcdf.log
export netcdf_prefix=$LOCAL/netcdf

prefix=$LOCAL/udunits2 build_dir=$BUILD ./udunits2.sh | tee udunits2.log
export udunits_prefix=$LOCAL/udunits2

prefix=$LOCAL/proj build_dir=$BUILD ./proj.sh | tee proj.log
export proj_prefix=$LOCAL/proj

# Build PETSc and PISM using Intel's icc
export CC=icc
# Note: icc can compile both C and C++ code
export CXX=icc
export MPICC="mpicc -cc=$CC"
export MPICXX="mpicxx -cxx=$CXX"
# Support all CPUs on Pleiades and select an optimized version at runtime:
export opt_flags="-axCORE-AVX512,CORE-AVX2 -xAVX -fp-model precise -diag-disable=cpu-dispatch"

prefix=$LOCAL/petsc build_dir=$BUILD ./petsc.sh | tee petsc.log
export PETSC_DIR=$LOCAL/petsc

prefix=$LOCAL/pism build_dir=$BUILD/pism ./pism.sh | tee pism.log
