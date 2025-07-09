#!/bin/bash

set -e
set -u
set -x

# Install yaxt and yac in  /opt/yac,
# using /var/tmp/build/yac as the build directory.

N=${N:-12}
MPICC=${MPICC:-mpicc}

opt_flags=${opt_flags:--mavx2}
prefix=${prefix:-/opt/yac}
build_dir=${build_dir:-/var/tmp/build/yac}

mkdir -p ${build_dir}
cd ${build_dir}

rm -rf yac

yac_version=3.7.1
git clone -b release-${yac_version} \
    https://gitlab.dkrz.de/dkrz-sw/yac.git

cd yac

autoreconf -i


./configure --prefix=${prefix} \
            --with-yaxt-root=${prefix} \
	    --with-fyaml-root=${libfyaml_prefix} \
            --disable-netcdf \
            --disable-examples \
            --disable-tools \
            --disable-deprecated \
            --disable-fortran-bindings \
            --with-pic \
            --with-external-lapack=lapacke \
            --with-netlib-root=${NETLIB_LAPACK_HOME} \
	    CC="${MPICC}" \
	    CFLAGS="${opt_flags}"




make -j $N all 2>&1 | tee yac_compile.log
make -j $N install 2>&1 | tee yac_install.log
make -j $N check 2>&1 | tee yac_check.log
