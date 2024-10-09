#!/bin/bash

set -u
set -e
set -x

# Install parallel NetCDF using parallel HDF5 in /opt/hdf5 and
# /var/tmp/build/netcdf as the build directory.

MPICC=${MPICC:-mpicc}

hdf5_prefix=${hdf5_prefix:-/opt/hdf5}

version=4.9.2
prefix=${prefix:-/opt/netcdf}
build_dir=${build_dir:-/var/tmp/build/netcdf}
url=https://downloads.unidata.ucar.edu/netcdf-c/${version}/netcdf-c-${version}.tar.gz
mkdir -p ${build_dir}
cd ${build_dir}

wget -nc ${url}

rm -rf netcdf-c-${version}
tar zxf netcdf-c-${version}.tar.gz

cd netcdf-c-${version}

# hdf5_prefix=/nasa/hdf5/1.12.0_mpt

export MPICXX_CXX=icpc
export MPIF90_F90=ifort
export MPICC_CC=icc

./configure CC="${MPICC}" CPPFLAGS=-I${hdf5_prefix}/include LDFLAGS=-L${hdf5_prefix}/lib \
        --enable-netcdf4 \
        --disable-dap \
        --prefix=${prefix} 2>&1 | tee netcdf_configure.log

make all -j 12 2>&1 | tee netcdf_compile.log
make install -j 12  2>&1 | tee netcdf_install.log
