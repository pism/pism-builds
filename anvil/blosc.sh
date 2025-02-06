#!/bin/bash

set -e
set -u
set -x

# Install blosc /opt/c-blosc,
# using /var/tmp/build/c-bloscl as the build directory.

MPICC=${MPICC:-mpicc}

opt_flags=${opt_flags:--mavx2}
prefix=${prefix:-/opt/c-blosc}
build_dir=${build_dir:-/var/tmp/build/c-blosc}

mkdir -p ${prefix}
mkdir -p ${build_dir}
cd ${build_dir}

rm -rf c-blosc
git clone git@github.com:Blosc/c-blosc.git
cd c-blosc

CC="${MPICC}" CXX="${MPICXX}" cmake \
    -B ${build_dir}/c-blosc/build \
    -S ${build_dir}/c-blosc \
    -DCMAKE_CXX_FLAGS="${opt_flags}" \
    -DCMAKE_C_FLAGS="${opt_flags}" \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_PREFIX_PATH="${blosc_prefix}"
    2>&1 | tee blosc_configure.log

make -j 128 VERBOSE=1 -C ${build_dir}/c-blosc/build 2>&1 install | tee blosc_compile.log

