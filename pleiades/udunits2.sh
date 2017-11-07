#!/bin/bash

set -e
set -x
set -u

N=8

build_udunits2() {
    version=2.2.25

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-${version}.tar.gz

    tar -zxvf udunits-${version}.tar.gz

    cd udunits-${version}

    CC=gcc ./configure --prefix=$LOCAL_LIB_DIR 2>&1 | tee udunits_configure.log

    make all -j $N 2>&1 | tee udunits_make.log
    make install 2>&1 | tee udunits_install.log
}

build_udunits2
