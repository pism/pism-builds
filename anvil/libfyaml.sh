#!/bin/bash

set -e
set -u
set -x

# Install libf yaml/opt/libfyaml,
# using /var/tmp/build/libfyaml as the build directory.

MPICC=${MPICC:-mpicc}

prefix=${prefix:-/opt/libfyaml}
build_dir=${build_dir:-/var/tmp/build/libfyaml}

mkdir -p ${prefix}
mkdir -p ${build_dir}
cd ${build_dir}

rm -rf libfyaml

git clone https://github.com/pantoniou/libfyaml.git

cd libfyaml

./bootstrap.sh

./configure CC="$MPICC" CXX="$MPICXX" --disable-static --prefix=${prefix} \


make -j 1 all 2>&1 | tee libfyaml_compile.log
make -j 1 install 2>&1 | tee libfyam_install.log
