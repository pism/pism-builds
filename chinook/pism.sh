#!/bin/bash

set -e
set -u
set -x

N=${N:-12}
opt_flags="-O3 -axCORE-AVX2 -xSSE4.2 -fp-model=precise"


# run as version=v2.0 ./pism.sh to build v2.0, etc
version=${version:-dev}


# Compilers:
export MPICC=${MPICC:-mpicc}
export MPICXX=${MPICXX:-mpicxx}

# Prerequisites:
export PETSC_DIR=${PETSC_DIR:-/opt/petsc}

# Installation prefix and build location:
prefix=${prefix:-/opt/pism}
build_dir=${build_dir:-/var/build/pism}

echo $prefix
echo $build_dir
mkdir -p ${build_dir}

pushd ${build_dir}
git clone https://github.com/pism/pism.git . || (git checkout main && git pull)
git checkout ${version}
git pull
rm -rf build
mkdir -p build
popd


echo $yac_prefix

export CC=icx
export CXX=icpx
# Silence OpenMPI's error message about a part of its system that is not available on login nodes
export OMPI_MCA_plm_rsh_agent=""
cmake \
    -B ${build_dir}/build \
    -S ${build_dir} \
    -DCMAKE_PREFIX_PATH="${yac_prefix};${libfyaml_prefix}" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_FLAGS="${opt_flags} -diag-disable=cpu-dispatch,10006,2102" \
    -DCMAKE_C_FLAGS="${opt_flags} -diag-disable=cpu-dispatch,10006" \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DPism_USE_YAC_INTERPOLATION=YES \
    -DHDF5_PREFER_PARALLEL=TRUE \
    -DPism_USE_PARALLEL_NETCDF4=YES \
    -DPism_BUILD_PYTHON_BINDINGS=OFF \
    -DPism_USE_PIO=NO \
    -DPism_USE_PNETCDF=NO \
    -DPism_USE_PROJ=YES  
  

make -j $N VERBOSE=1 -C ${build_dir}/build install
