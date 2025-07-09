#!/bin/bash

set -e
set -x

# Make sure PETSC_DIR is already set before running this script

echo 'PETSC_DIR = ' ${PETSC_DIR}

build_petsc() {

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone -b v3.21.5  https://gitlab.com/petsc/petsc.git .

    python ./config/configure.py \
	    --with-cc=$MPICC \
	    --with-cxx=$MPICXX \
           --with-shared-libraries \
           --with-debugging=1 \
           --with-fc=0 \
           --with-x=0 \
	   --with-64-bit-indices \
           --with-petsc4py \
           COPTFLAGS='-O3' \
           CXXOPTFLAGS='-O3' \

    make all
}



build_petsc
