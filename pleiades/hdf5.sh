#!/bin/bash

set -e
set -u
set -x

# Install HDF5 1.12.0 with parallel I/O in /opt/hdf5,
# using /var/tmp/build/hdf5 as the build directory.

MPICC=${MPICC:-mpicc}

version=1.12.0
prefix=${prefix:-/opt/hdf5}
build_dir=${build_dir:-/var/tmp/build/hdf5}
hdf5_site=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12
url=${hdf5_site}/hdf5-${version}/src/hdf5-${version}.tar.gz

mkdir -p ${build_dir}
cd ${build_dir}

wget -nc ${url}

rm -rf hdf5-${version}
tar xzf hdf5-${version}.tar.gz

cd hdf5-${version}

export MPI_TYPE_DEPTH=50
export MPICXX_CXX=icpc
export MPIF90_F90=ifort
export MPICC_CC=icc

./configure CC=icc CXX=icpc CFLAGS=-w \
  --enable-parallel \
  --enable-unsupported \
  --prefix=${prefix} 2>&1 | tee hdf5_configure.log

make -j 16 all 2>&1 | tee hdf5_compile.log
make -j 16 install 2>&1 | tee hdf5_install.log
make -j 16 test  2>&1 | tee hdf5_test.log
