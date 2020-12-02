#!/bin/bash

set -x
set -e
set -u

build_proj() {
    # download and build PROJ
    mkdir -p $LOCAL_LIB_DIR/sources/proj
    cd $LOCAL_LIB_DIR/sources/proj

    git clone --depth 1 -b 6.3 https://github.com/OSGeo/proj.git . || git pull

    # remove and re-generate files created by autoconf
    export SQLITE3_LIBS=$LOCAL_LIB_DIR
    autoreconf --force --install
    ./configure --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_proj

