#!/bin/bash

set -e
set -u
set -x

# Install yaxt and yac in  /opt/yac,
# using /var/tmp/build/yac as the build directory.

MPICC=${MPICC:-mpicc}

prefix=${prefix:-/opt/yac}
build_dir=${build_dir:-/var/tmp/build/yac}

mkdir -p ${build_dir}
cd ${build_dir}

rm -rf yac

yac_version=3.5.2
git clone -b release-${yac_version} \
    https://gitlab.dkrz.de/dkrz-sw/yac.git

cd yac

autoreconf -i

./configure --prefix=${prefix} \
            --with-yaxt-root=${yaxt_prefix} \
            --disable-netcdf \
            --disable-examples \
            --disable-tools \
            --disable-deprecated \
            --with-pic \
            CC="$MPICC" \
            CFLAGS="-O3 -g -march=native" \
            FC="$MPIF90" \
	    --disable-mpi-checks 



make -j 1 all 2>&1 | tee yac_compile.log
make -j 1 install 2>&1 | tee yac_install.log

