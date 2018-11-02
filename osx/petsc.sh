#!/bin/bash

set -e
set -x

# Make sure PETSC_DIR and PETSC_ARCH are already set before running this script

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

FLAGS="-O3"

configure_and_build() {

    sixty_four=$1
    debugging=$2

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .

    python2.7 ./config/configure.py \
        --with-shared-libraries \
        --with-fc=0 \
        --with-debugging=${debugging} \
        --with-64-bit-indices=${sixty_four} \
        --COPTFLAGS=$FLAGS CXXOPTFLAGS=$FLAGS
    

    make all
}


build_petsc4py() {
    PETSC4PY_DIR=$HOME/petsc4py
    
    rm -rf $PETSC4PY_DIR
    mkdir -p $PETSC4PY_DIR
    cd $PETSC4PY_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc4py .
    python setup.py install --user
    
}

# build_petsc
build_petsc4py
