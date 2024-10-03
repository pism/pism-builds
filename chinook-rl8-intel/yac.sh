#!/bin/bash

set -u
set -e
set -x

rm -rf yaxt
rm -rf yac

prefix=$LOCAL_LIB_DIR

yaxt_version=0.11.2
git clone -b release-${yaxt_version} \
    https://gitlab.dkrz.de/dkrz-sw/yaxt.git

cd yaxt

autoreconf -i

./configure --prefix=${prefix} \
            --with-pic \
	    CC="mpicc -cc=icx" \
	    CFLAGS="-O3 -g -march=native" \
	    FC=mpiifort

make all && make install

cd -

yac_version=3.3.0
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
            --with-pic \
	    CC="mpicc -cc=icx" \
	    CFLAGS="-O3 -g -march=native" \
	    FC=mpiifort

make all && make install
