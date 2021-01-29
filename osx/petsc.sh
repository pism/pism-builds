#!/bin/bash

set -e
set -x

# Make sure PETSC_DIR and PETSC_ARCH are already set before running this script

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

FLAGS="-O3"

build_petsc() {

    sixty_four=$1
    debugging=$2

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    python ./config/configure.py \
        --with-shared-libraries \
        --with-fc=0 \
        --download-petsc4py \
        --with-debugging=${debugging} \
        --with-64-bit-indices=${sixty_four} \
        --COPTFLAGS=$FLAGS CXXOPTFLAGS=$FLAGS
    

    make all
}



build_petsc 0 0
