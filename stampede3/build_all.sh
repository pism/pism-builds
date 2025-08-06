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

export CXX=icpx
export CC=icx

export MPICC="mpicc -cc=icx"
export MPICXX="mpicxx -cxx=icpx"
export MPIF90="mpif90 -f90=ifx"

export MPICXX_CXX="mpicxx -cxx=icpx"
export MPIF90_F90="mpif90 -f90=ifx"
export MPICC_CC="mpicc -cxx=icx"

export N=8
export opt_flags="-xCORE-AVX512 -O3"

echo "local_dir=${LOCAL}"
echo "build_dir=${BUILD}"

export prefix=$LOCAL/libfyaml
export build_dir=$BUILD
${SET_ENV} || ./libfyaml.sh | tee libfyaml.log
export libfyaml_prefix=$LOCAL/libfyaml

export prefix=$LOCAL/yac
export build_dir=$BUILD
${SET_ENV} || ./yaxt.sh | tee yaxt.log
export yaxt_prefix=$LOCAL/yac

export prefix=$LOCAL/yac
export build_dir=$BUILD
${SET_ENV} || ./yac.sh | tee yac.log
export yac_prefix=$LOCAL/yac

#export PETSC_DIR=$LOCAL/petsc
#export PETSC_ARCH="arch-linux-c-debug"
#${SET_ENV} || ./petsc.sh | tee petsc.log

export version=dev
export prefix=$LOCAL/pism
export build_dir=$BUILD/pism

./pism.sh
