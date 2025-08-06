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

rm -rf yaxt

yaxt_version=0.11.4
git clone -b release-${yaxt_version} \
    https://gitlab.dkrz.de/dkrz-sw/yaxt.git

cd yaxt

autoreconf -i

./configure --prefix=${prefix} \
            CFLAGS="-O3 -g ${opt_flags}" CC="$MPICC" FC=no --with-pic 


make -j $N all 2>&1 | tee yaxt_compile.log
make -j $N install 2>&1 | tee yaxt_install.log
make -j $N check 2>&1 | tee yaxt_check.log
cd -


