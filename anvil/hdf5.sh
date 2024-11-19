#!/bin/bash

set -e
set -u
set -x

# Install HDF5 1.12.0 with parallel I/O in /opt/hdf5,
# using /var/tmp/build/hdf5 as the build directory.

MPICC=${MPICC:-mpicc}

version=1.14.5
prefix=${prefix:-/opt/hdf5}

build_dir=${build_dir:-/var/tmp/build/hdf5}
opt_flags=${opt_flags:--mavx2}

hdf5_site=https://support.hdfgroup.org/releases/hdf5/v1_14/v1_14_5/downloads
url=${hdf5_site}/hdf5-${version}.tar.gz

mkdir -p ${prefix}
mkdir -p ${build_dir}
cd ${build_dir}

wget -nc ${url}

rm -rf hdf5-${version}
tar xzf hdf5-${version}.tar.gz

cd hdf5-${version}

export MPI_TYPE_DEPTH=50

CC="${MPICC}" CXX="${MPICXX}" cmake \
    -B ${build_dir}/hdf5-${version}/build \
    -S ${build_dir}/hdf5-${version} \
    -DBUILD_SHARED_LIBS=ON \
    -DHDF5_ENABLE_SZIP=NO \
    -DHDF5_ENABLE_PARALLEL=YES \
    -DHDF5_ENABLE_THREADSAFE=YES \
    -DCMAKE_CXX_FLAGS="${opt_flags}" \
    -DCMAKE_C_FLAGS="${opt_flags}" \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_PREFIX_PATH="${blosc_prefix}" \
    2>&1 | tee hdf5_configure.log

make -j 128 VERBOSE=1 -C ${build_dir}/hdf5-${version}/build 2>&1 install  | tee hdf5_compile.log
