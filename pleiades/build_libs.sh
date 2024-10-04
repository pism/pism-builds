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

export MPICC="mpicc -cc=icx"
export MPICXX="mpicxx -cxx=icx"
export MPIF90="mpif90 -f90=ifx"

export MPICXX_CXX="mpicxx -cxx=icx"
export MPIF90_F90="mpif90 -f90=ifx"
export MPICC_CC="mpicc -cxx=icx"


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

export prefix=$LOCAL/ncview
export build_dir=$BUILD
${SET_ENV} || ./ncview.sh | tee ncview.log
export ncview_prefix=$LOCAL/ncview

export prefix=$LOCAL/proj
export build_dir=$BUILD
${SET_ENV} || ./proj.sh | tee proj.log
export proj_prefix=$LOCAL/proj

export prefix=$LOCAL/cdo
export build_dir=$BUILD
${SET_ENV} || ./cdo.sh | tee cdo.log
export cdo_prefix=$LOCAL/cdo


${SET_ENV} || ./petsc-mumps.sh | tee petsc.log
export PETSC_DIR=$LOCAL/petsc
