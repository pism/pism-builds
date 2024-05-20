#!/bin/bash

set -e
set -x

# Make sure PETSC_DIR and PETSC_ARCH are already set before running this script

echo 'PETSC_DIR = ' ${PETSC_DIR}

build_petsc() {

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b main https://gitlab.com/petsc/petsc.git .

    python ./config/configure.py \
	    --with-cc=mpicc \
	    --with-cxx=mpicxx \
           --with-shared-libraries \
           --with-debugging=0 \
           --with-fc=0 \
	   --with-64-bit-indices \
           --with-petsc4py \
           COPTFLAGS='-O3' \
           CXXOPTFLAGS='-O3' \

    make all
}



build_petsc
