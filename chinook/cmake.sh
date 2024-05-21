#!/bin/bash

build_dir=${build_dir:-/var/tmp/build/cmake}
prefix=${prefix:-$HOME/local}
url=https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3.tar.gz

mkdir -p ${build_dir}
cd ${build_dir}

wget -nc ${url}

rm -rf cmake-3.28.3
tar xzf cmake-3.28.3.tar.gz

cd cmake-3.28.3

./configure \
        --prefix=${prefix} 2>&1 | tee cmake_configure.log

make all -j 12 2>&1 | tee cmake_compile.log
make install -j 12  2>&1 | tee cmake_install.log
