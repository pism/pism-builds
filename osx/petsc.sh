#!/bin/bash

set -e
set -x

# Make sure PETSC_DIR and PETSC_ARCH are already set before running this script

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

build_petsc() {

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b release https://gitlab.com/petsc/petsc.git .

    python ./config/configure.py \
           --with-debugging=${debugging} \
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

    make all
}



build_petsc
