#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}

optimization_flags="-O3"

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b v3.20.6 https://gitlab.com/petsc/petsc.git .

    ./config/configure.py \
        --march=native \
        --with-cc=mpiicc \
        --with-fc=mpiifort \
        --with-cxx=mpiicpc \
        --CFLAGS="${optimization_flags}" \
        --CXXOPTFLAGS="${optimization_flags}" \
        --known-mpi-shared-libraries=1 \
	--with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
	--download-petsc4py \
        --with-ssl=0 \
        --with-batch=1 \
        --with-shared-libraries=1 \
	--download-metis \
	--download-parmetis \
	--download-mumps \
        --with-64-bit-indices \
        --with-scalapack-lib="-L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64" \
	--with-blas-lapack-dir=$MKLROOT/lib/intel64  | tee petsc-configure.log

    make all | tee petsc-build.log
}

build_petsc


#        --known-64-bit-blas-indices \
