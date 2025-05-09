#!/bin/bash

N=${N:-12}

prefix=${prefix:-/opt/libfyaml}
build_dir=${build_dir:-/var/tmp/build/libfyaml}

mkdir -p ${build_dir}
cd ${build_dir}

rm -rf libfyaml

git clone https://github.com/pantoniou/libfyaml.git

cd libfyaml

./bootstrap.sh

./configure --prefix=${prefix}

make all -j $N

make install
