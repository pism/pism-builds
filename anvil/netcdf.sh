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
opt_flags=${opt_flags:--mavx2}


url=https://downloads.unidata.ucar.edu/netcdf-c/${version}/netcdf-c-${version}.tar.gz

mkdir -p ${prefix}
mkdir -p ${build_dir}

pushd ${build_dir}

wget -nc ${url}

rm -rf netcdf-c-${version}
tar zxf netcdf-c-${version}.tar.gz

cd netcdf-c-${version}
rm -rf build
mkdir -p build
popd


CC="${MPICC}" CXX="${MPICXX}" cmake \
    -B ${build_dir}/netcdf-c-${version}/build \
    -S ${build_dir}/netcdf-c-${version} \
    -DENABLE_PARALLEL=ON \
    -DENABLE_DAP=OFF \
    -DENABLE_NETCDF_4=ON \
    -DCMAKE_CXX_FLAGS="${opt_flags}" \
    -DCMAKE_C_FLAGS="${opt_flags}" \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_PREFIX_PATH="${hdf5_prefix};${blosc_prefix}" \
    2>&1 | tee netcf_configure.log

make -j 128 VERBOSE=1 -C ${build_dir}/netcdf-c-${version}/build 2>&1 install test | tee netcdf_compile.log

