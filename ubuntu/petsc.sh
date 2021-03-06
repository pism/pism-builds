#!/bin/bash

set -e
set -x

prefix=${HOME}/local/petsc

configure_and_build() {
    sixty_four=$1
    debugging=$2
    ./config/configure.py \
        --with-shared-libraries \
        --with-fc=0 \
        --with-debugging=${debugging} \
        --with-64-bit-indices=${sixty_four}

    make all
}

build_petsc() {
    version=3.10.0

    mkdir -p ${prefix}
    cd ${prefix}
    wget -nc http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz
    tar xzf petsc-${version}.tar.gz

    cd petsc-${version}
    export PETSC_DIR=$PWD

    export PETSC_ARCH=opt-32bit
    if [ "$2" = "1" ]; then
        export PETSC_ARCH=dbg-32bit
    fi
    configure_and_build $1 $2
}

build_petsc $1 $2
