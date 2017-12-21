#!/bin/bash

set -x
set -e
set -u

N=8

build_zlib() {

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://zlib.net/zlib-1.2.11.tar.gz
    tar -zxvf zlib-1.2.11.tar.gz
    cd zlib-1.2.11

    ./configure --prefix=${LOCAL_LIB_DIR} 2>&1 | tee zlib_configure.log

    make -j $N 2>&1 | tee zlib_compile.log
    make install 2>&1 | tee zlib_install.log
}

build_zlib
