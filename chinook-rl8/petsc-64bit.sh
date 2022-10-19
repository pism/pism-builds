#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}

MKL=/usr/local/pkg/Core/imkl/2022.1.0/mkl/2022.1.0/lib/intel64
optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -fp-model precise"

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    # Note that on Chinook mpicc and mpicxx wrap Intel's C and C++ compilers
    ./config/configure.py \
        --march native \
        --with-cc=icc \
        --with-fc=0 \
        --with-cxx=icx \
        --CFLAGS="${optimization_flags}" \
        --known-mpi-shared-libraries=1 \
        --with-blas-lapack-dir=${MKL} \
        --known-64-bit-blas-indices \
        --with-64-bit-indices \
	--with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1 \
        --with-shared-libraries=1

    make all
}

build_petsc
