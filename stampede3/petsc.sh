#!/bin/bash

set -e
set -u
set -x

echo $MPICC
echo $MPICXX
echo $MPIF90

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    ./config/configure.py \
        --with-debugging=1 \
        --with-shared \
	--with-fc=0 \
	--with-cc="$MPICC" \
        --with-cxx="$MPICXX" \
        --with-cpp=/usr/bin/cpp \
        --with-gnu-compilers=0 \
        --with-vendor-compilers=intel \
        --with-64-bit-indices \
        COPTFLAGS='-g -Ofast'   \
        CXXOPTFLAGS='-g -Ofast' \
	--with-64-bit-indices \
	--with-blas-lapack-dir=$MKLROOT/lib/intel64 | tee petsc-configure.log

    make all | tee petsc-build.log
}

build_petsc

