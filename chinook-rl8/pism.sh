#!/bin/bash

set -e
set -u
set -x

optimization_flags=" "

# No. of cores for make
N=8

branch=dev
if [ $# -gt 0 ] ; then  # if user says "pism.sh frontal-melt" then use "frontal-melt" branch
  branch="$1"
fi

hdf5_prefix=${hdf5_prefix:-/opt/hdf5}
netcdf_prefix=${netcdf_prefix:-/opt/netcdf}
pnetcdf_prefix=${pnetcdf_prefix:-/opt/pnetcdf}
parallelio_prefix=${parallelio_prefix:-/opt/parallelio}
udunits_prefix=${udunits_prefix:-/opt/udunits}
proj_prefix=${proj_prefix:-/opt/proj}

set -e
set -x
mkdir -p $PISM_DIR/sources
cd $PISM_DIR/sources

git clone  --no-single-branch https://github.com/pism/pism.git . || git pull

git checkout $branch

rm -rf build
mkdir -p build
cd build

export CC=mpicc
export CXX=mpicxx
# Silence OpenMPI's error message about a part of its system that is not available on login nodes
export OMPI_MCA_plm_rsh_agent=""
cmake -DCMAKE_CXX_FLAGS="${optimization_flags}" \
      -DCMAKE_C_FLAGS="${optimization_flags}" \
      -DCMAKE_PREFIX_PATH="${hdf5_prefix};${netcdf_prefix};${pnetcdf_prefix};${parallelio_prefix};${udunits2_prefix};${proj_prefix}" \
      -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
      -DPism_BUILD_PYTHON_BINDINGS=OFF \
      -DPism_USE_JANSSON=NO \
      -DPism_USE_PARALLEL_NETCDF4=YES \
      -DPism_USE_PROJ=YES \
      $PISM_DIR/sources
make -j $N install
set +x
set +e

