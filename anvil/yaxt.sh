#!/bin/bash

set -e
set -u
set -x

# Install yaxt and yac in  /opt/yac,
# using /var/tmp/build/yac as the build directory.

MPICC=${MPICC:-mpicc}

opt_flags=${opt_flags:--mavx2}
prefix=${prefix:-/opt/yac}
build_dir=${build_dir:-/var/tmp/build/yac}

mkdir -p ${build_dir}
cd ${build_dir}

rm -rf yaxt

yaxt_version=0.11.2
git clone -b release-${yaxt_version} \
    https://gitlab.dkrz.de/dkrz-sw/yaxt.git

cd yaxt

autoreconf -i

./configure --prefix=${prefix} \
            --with-pic --without-regard-for-quality \
            CFLAGS="-O3 -g ${opt_flags}" CC="$MPICC" FC="$MPIF90" FCFLAGS="${opt_flags}" \


make -j 128 all 2>&1 | tee yaxt_compile.log
make -j 128 install 2>&1 | tee yaxt_install.log

cd -


