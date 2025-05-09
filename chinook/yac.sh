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


yaxt_version=0.11.4

mkdir -p yaxt
cd yaxt

git clone https://gitlab.dkrz.de/dkrz-sw/yaxt.git . || git pull
git checkout release-${yaxt_version}
git pull


autoreconf -i

./configure --prefix=${prefix} \
            --with-pic \
            --disable-xt-ddt-exchanger \
	    CC="mpicc -cc=icx" \
	    CFLAGS="-O3 -march=native" \
	    FC=no

make -j $N all 2>&1 | tee yaxt_compile.log
make -j $N install 2>&1 | tee yaxt_install.log
make -j $N check 2>&1 | tee yaxt_check.log

cd -

yac_version=3.7.0

mkdir -p yac
cd yac

git clone https://gitlab.dkrz.de/dkrz-sw/yac.git . || git pull
git checkout release-${yac_version}
git pull


autoreconf -i

./configure --prefix=${prefix} \
            --with-yaxt-root=${prefix} \
	    --with-fyaml-root=${libfyaml_prefix} \
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
#make -j $N check 2>&1 | tee yac_check.log
