#!/bin/bash

set -x
set -e
set -u

# run as version=v2.0 ./pism.sh to build v2.0, etc
version=${version:-dev}

opt_flags=${opt_flags:--mavx2 -xCORE-AVX2 -axCORE-AVX512,MIC-AVX512}


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

# Compilers:
export MPICC=${MPICC:-mpicc}
export MPICXX=${MPICXX:-mpicxx}

# Prerequisites:
export PETSC_DIR=${PETSC_DIR:-/opt/petsc}
build_dir=${PISM_DIR:-/var/build/pism}
prefix=${PISM_DIR:-/opt/pism}

mkdir -p ${build_dir}

pushd ${build_dir}
git clone https://github.com/pism/pism.git . || (git checkout main && git pull)
git checkout ${version}
git pull
rm -rf build
mkdir -p build
popd


cmake -DCMAKE_CXX_FLAGS="${opt_flags}" \
      -DCMAKE_C_FLAGS="${opt_flags}" \
      -B ${build_dir}/build \
      -S ${build_dir} \
      -DCMAKE_PREFIX_PATH="${hdf5_prefix};${netcdf_prefix};${pnetcdf_prefix};${parallelio_prefix};${udunits_prefix}" \
      -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
      -DPism_BUILD_PYTHON_BINDINGS=OFF \
      -DPism_USE_JANSSON=NO \
      -DPism_USE_PARALLEL_NETCDF4=YES \
      -DPism_USE_PROJ=YES \
      $PISM_DIR


make -C ${build_dir}/build install
