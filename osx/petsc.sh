#!/bin/bash

set -e
set -x

prefix=${HOME}/local/petsc

configure_and_build() {
    sixty_four=$1
    debugging=$2
    python2.7 ./config/configure.py \
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
    configure_and_build 0 0
}

build_petsc
