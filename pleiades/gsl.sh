#!/bin/bash

set -e
set -u
set -x

# Install gsl in  /opt/gsl,
# using /var/tmp/build/gsl as the build directory.


prefix=${prefix:-/opt/gsl}
build_dir=${build_dir:-/var/tmp/build/gsl}

mkdir -p ${build_dir}
cd ${build_dir}


build_gsl() {

    # download and build GSL
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    version=2.8
    url=ftp://ftp.gnu.org/gnu/gsl/gsl-${version}.tar.gz

    wget -nc ${url}
    tar xzvf gsl-${version}.tar.gz

    cd gsl-${version}

    ./configure \
      --prefix=${prefix} 2>&1 | tee gsl_configure.log

    make all -j 4 2>&1 | tee gsl_compile.log
    make install 2>&1 | tee gsl_install.log

}

build_gsl
