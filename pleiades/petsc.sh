#!/bin/bash

set -e
set -x
set -u

N=8

build_petsc() {
    # rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git . || git pull

    opt_flags="-g -O3 -axCORE-AVX2,AVX -xSSE4.2"

    ./config/configure.py \
	--with-cc=icc \
	--known-mpi-shared-libraries=1 \
	--COPTFLAGS="${opt_flags}" \
	--with-cxx=icpc \
	--with-cpp=/usr/bin/cpp \
	--with-fc=0 \
        --download-petsc4py \
	--with-vendor-compilers=intel \
	--with-gnu-compilers=0 \
	--with-blas-lapack-dir=${MKLROOT}/lib/intel64 \
        --with-64-bit-indices=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1

PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH make all
PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH make check

}

build_petsc
