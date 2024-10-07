#!/bin/bash

set -x
set -e
set -u

# run as version=v2.0 ./pism.sh to build v2.0, etc
version=${version:-dev}

opt_flags=${opt_flags:--mavx2}

# Compilers:
export MPICC=${MPICC:-mpicc}
export MPICXX=${MPICXX:-mpicxx}

# Prerequisites:
export PETSC_DIR=${PETSC_DIR:-/opt/petsc}
hdf5_prefix=${hdf5_prefix:-/opt/hdf5}
netcdf_prefix=${netcdf_prefix:-/opt/netcdf}
pnetcdf_prefix=${pnetcdf_prefix:-/opt/pnetcdf}
parallelio_prefix=${parallelio_prefix:-/opt/parallelio}
udunits_prefix=${udunits_prefix:-/opt/udunits}
proj_prefix=${proj_prefix:-/opt/proj}

# Installation prefix and build location:
prefix=${prefix:-/opt/pism}
build_dir=${build_dir:-/var/build/pism}

mkdir -p ${build_dir}

pushd ${build_dir}
git clone https://github.com/pism/pism.git . || (git checkout main && git pull)
git checkout ${version}
git pull
rm -rf build
mkdir -p build
popd

CC="${MPICC}" CXX="${MPICXX}" cmake \
    -B ${build_dir}/build \
    -S ${build_dir} \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_FLAGS="${opt_flags}" \
    -DCMAKE_C_FLAGS="${opt_flags}" \
    -DCMAKE_PREFIX_PATH="${yac_prefix};${yaxt_prefix};${hdf5_prefix};${netcdf_prefix};${pnetcdf_prefix};${parallelio_prefix};${proj_prefix}" \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DPism_USE_YAC_INTERPOLATION=YES \
    -DPism_USE_PARALLEL_NETCDF4=YES \
    -DPism_BUILD_PYTHON_BINDINGS=ON \
    -DPism_USE_PIO=NO \
    -DPism_USE_PNETCDF=NO \
    -DPism_USE_PROJ=YES 
  

make -j 8 -C ${build_dir}/build install
