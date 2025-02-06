#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}

MKL=/apps/anvil/external/apps/intel/oneapi/2024.1/mkl/2024.1/lib/

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}

optimization_flags="-O3"

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    ./config/configure.py \
        --march=native \
        --with-fc=0 \
	--with-cc="$MPICC" \
        --with-cxx="$MPICXX" \
        --CFLAGS="${optimization_flags}" \
        --CXXOPTFLAGS="${optimization_flags}" \
        --known-mpi-shared-libraries=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1 \
        --with-shared-libraries=1 \
        --with-64-bit-indices \
        --with-blas-lapack-dir=$MKL  | tee petsc-configure.log

    make all | tee petsc-build.log
}

build_petsc

