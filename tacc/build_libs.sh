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

export LOCAL=$WORK/local/
export BUILD=$WORK/local/build/

# Build most dependencies using GCC
export CC=gcc
export CXX=g++
export MPICC="mpicc -cc=$CC"
export MPICXX="mpicxx -cxx=$CXX"

export prefix=$LOCAL/udunits2
export build_dir=$BUILD
${SET_ENV} || ./udunits2.sh | tee udunits2.log
export udunits_prefix=$LOCAL/udunits2

export prefix=$LOCAL/proj
export build_dir=$BUILD
${SET_ENV} || ./proj.sh | tee proj.log
export proj_prefix=$LOCAL/proj

export PETSC_DIR=/home1/apps/intel18/impi18_0/petsc/3.16/
