#!/bin/bash

set -e
set -u
set -x

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

MKL=/usr/local/pkg/numlib/imkl/2019.3.199-pic-iompi-2019b/mkl/lib/intel64
optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise"

build_petsc() {
    # rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    # git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    # Note that on Chinook mpicc and mpicxx wrap Intel's C and C++ compilers
    # ./config/configure.py \
    #     --download-petsc4py \
    #     --with-cc=mpicc \
    #     --with-cxx=mpicxx \
    #     --with-fc=mpifort \
    #     --download-scalapack \
    #     --download-mumps \
    #     --download-f2cblaslapack \
    #     COPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
    #     CXXOPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
    #     FOPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
    #     --known-mpi-shared-libraries=1 \
    #     --with-debugging=0 \
    #     --with-valgrind=0 \
    #     --with-x=0 \
    #     --with-ssl=0 \
    #     --with-batch=1 \
    #     --with-shared-libraries=1
    
    ./configure \
     --with-cc=mpicc \
     --with-cxx=mpicxx \
     --with-fc=mpifort \
     --with-shared-libraries \
     --with-debugging=0 \
     --with-petsc4py \
     COPTFLAGS='-O3 -march=native -mtune=native' \
     CXXOPTFLAGS='-O3 -march=native -mtune=native' \
     FOPTFLAGS='-O3 -march=native -mtune=native' \
     --download-f2cblaslapack \
     --download-mumps \
     --download-scalapack

    ./configure \
     --with-cc=mpicc \
     --with-cxx=mpicxx \
     --with-fc=mpifort \
     --with-shared-libraries \
     --with-debugging=0 \
     --with-petsc4py \
     COPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
     CXXOPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
     FOPTFLAGS='-O3 -march=native -mtune=native -axCORE-AVX2 -xSSE4.2 -ipo -fp-model=precise' \
     --download-f2cblaslapack \
     --download-mumps \
     --download-scalapack

make all
}

build_petsc

