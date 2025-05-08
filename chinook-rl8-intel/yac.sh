#!/bin/bash

set -u
set -e
set -x

rm -rf yaxt
rm -rf yac

prefix=$LOCAL_LIB_DIR

yaxt_version=0.11.3
git clone -b release-${yaxt_version} \
    https://gitlab.dkrz.de/dkrz-sw/yaxt.git

cd yaxt

autoreconf -i

./configure --prefix=${prefix} \
            --with-pic \
	    CC="mpicc -cc=icx" \
	    CFLAGS="-O3 -march=native" \
	    FC=no

make all && make install

cd -

yac_version=3.6.2
git clone -b release-${yac_version} \
    https://gitlab.dkrz.de/dkrz-sw/yac.git

cd yac

autoreconf -i

./configure --prefix=${prefix} \
            --with-yaxt-root=${prefix} \
	    --with-fyaml-root=${prefix} \
            --disable-netcdf \
            --disable-examples \
            --disable-tools \
            --disable-deprecated \
            --disable-fortran-bindings \
            --with-pic \
            --with-external-lapack=mkl \
            --with-mkl-root=${MKLROOT} \
            LDFLAGS="-qmkl=sequential" \
	    CC="mpicc -cc=icx" \
	    CFLAGS="-O3 -march=native"

make all && make install
