#!/bin/bash

set -x
set -e

url=git@github.com:NCAR/ParallelIO.git

build=~/local/build/parallelio
prefix=~/local/parallelio

rm -rf ${build}
mkdir -p ${build}/sources ${build}/build

git clone --depth=1 -b master ${url} ${build}/sources

CC=mpicc cmake -B ${build}/build -S ${build}/sources \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${prefix} \
  -DNetCDF_PATH=$HOME/local/netcdf \
  -DPnetCDF_PATH=$HOME/local/pnetcdf \
  -DPIO_ENABLE_FORTRAN=0 \
  -DPIO_ENABLE_TIMING=0

pushd ${build}/build

make -j4 install

popd
