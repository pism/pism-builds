#!/bin/bash

set -e
set -u
set -x

MKL=/nasa/intel/Compiler/2020.4.304/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin


build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    ./config/configure.py \
        --with-debugging=0 \
	--with-fc=0 \
        --with-petsc4py \
        --with-shared \
        --with-cc=mpicc \
        --with-cxx=mpicxx \
        --with-blaslapack-dir=$MKLROOT/lib/intel64 \
        --with-cpp=/usr/bin/cpp \
        --with-gnu-compilers=0 \
        --with-vendor-compilers=intel \
        --with-64-bit-indices \
        COPTFLAGS='-g -Ofast'   \
        CXXOPTFLAGS='-g -Ofast' \
        FOPTFLAGS='-g -Ofast'   \
        --download-make=yes \
	| tee petsc-configure.log

    make all | tee petsc-build.log
}

build_petsc

