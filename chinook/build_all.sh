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

export N=20
export LOCAL=$LOCAL_LIB_DIR
export BUILD=$LOCAL_LIB_DIR/build/

export CC=icx
export CXX=icx
export MPICC=mpiicc
export MPICXX=mpiicpc

export prefix=$LOCAL/libfyaml
export build_dir=$BUILD
${SET_ENV} || ./libfyaml.sh | tee libfyaml.log
export libfyaml_prefix=$LOCAL/libfyaml

export prefix=$LOCAL/yac
export build_dir=$BUILD
${SET_ENV} || ./yac.sh | tee yac.log
export yac_prefix=$LOCAL/yac


export PETSC_DIR=$LOCAL/petsc
${SET_ENV} || ./petsc-mumps.sh | tee petsc.log

# Build the dev branch:
export version=dev
export prefix=$LOCAL/pism
export build_dir=$BUILD/pism
./pism.sh
