#!/bin/bash

set -u
set -e
set -x

rm -rf yaxt
rm -rf yac

N=${N:-12}

prefix=${prefix:-/opt/yac}
libfyaml_prefix=${libfyaml_prefix:-/opt/libfyaml}
yaxt_prefix=${yaxt_prefix:-/opt/yaxt}
yac_prefix=${yac_prefix:-/opt/yac}

build_dir=${build_dir:-/var/tmp/build/yac}

mkdir -p ${build_dir}
cd ${build_dir}


yaxt_version=0.11.5.1
git clone -b release-${yaxt_version} \
    https://gitlab.dkrz.de/dkrz-sw/yaxt.git

cd yaxt

autoreconf -i

./configure --prefix=${prefix} FC=no \
            --with-pic

make all -j $N && make install

cd -

yac_version=3.14.0
git clone -b release-${yac_version} \
    https://gitlab.dkrz.de/dkrz-sw/yac.git

cd yac

test -f ./configure || ./autogen.sh

autoreconf -i

./configure --prefix=${prefix} \
            --with-yaxt-root=${prefix} \
	    --with-fyaml-root=${libfyaml_prefix} \
            --enable-python-bindings \
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

make -j $N all 2>&1 | tee yac_compile.log
make -j $N install 2>&1 | tee yac_install.log
make -j $N check 2>&1 | tee yac_check.log
