#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

MKL=/usr/local/pkg/numlib/imkl/11.3.3.210-pic-iompi-2016b/mkl/lib/intel64
optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .

    # Note that on Chinook mpicc and mpicxx wrap Intel's C and C++ compilers
    ./config/configure.py \
	--with-cc=mpicc \
	--with-cxx=mpicxx \
	--with-fc=0 \
	--CFLAGS="${optimization_flags}" \
	--known-mpi-shared-libraries=1 \
	--with-blas-lapack-dir=${MKL} \
	--with-64-bit-indices=1 \
	--with-debugging=0 \
	--with-valgrind=0 \
	--with-x=0 \
	--with-ssl=0 \
	--with-batch=1 \
	--with-shared-libraries=1

    # run conftest in an interactive job and wait for it to complete
    srun -t 20 -n 1 -N 1 -p debug mpirun ./conftest-$PETSC_ARCH

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_petsc
