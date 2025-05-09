#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}

optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise"

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b v3.23.1 https://gitlab.com/petsc/petsc.git .

    ./config/configure.py \
        --march=native \
        --with-cc="mpicc -cc=icx" \
        --with-fc=mpiifort \
        --with-cxx="mpicc -cc=icx" \
        --CFLAGS="${optimization_flags}" \
        --CXXOPTFLAGS="${optimization_flags}" \
        --FOPTFLAGS="${optimization_flags}" \
        --known-mpi-shared-libraries=1 \
	--with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1 \
        --download-mumps \
        --with-shared-libraries=1 \
        --with-64-bit-indices \
        --known-64-bit-blas-indices \
        --with-scalapack-lib="-L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64" \
	--with-blas-lapack-dir=$MKLROOT/lib/intel64  | tee petsc-configure.log
    

    make all
}

build_petsc

