#!/bin/bash

set -e
set -u
set -x

# Install libf yaml/opt/libfyaml,
# using /var/tmp/build/libfyaml as the build directory.

N=${N:-12}
MPICC=${MPICC:-mpicc}

opt_flags=${opt_flags:--mavx2}
prefix=${prefix:-/opt/libfyaml}
build_dir=${build_dir:-/var/tmp/build/libfyaml}

mkdir -p ${prefix}
mkdir -p ${build_dir}
cd ${build_dir}

rm -rf libfyaml

git clone https://github.com/pantoniou/libfyaml.git

cd libfyaml

./bootstrap.sh

./configure CC="$CC" CXX="$CXX" --disable-static --prefix=${prefix} \


make -j $N all 2>&1 | tee libfyaml_compile.log
make -j $N install 2>&1 | tee libfyam_install.log
