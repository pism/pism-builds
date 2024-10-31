#!/bin/bash

set -e
set -u
set -x

# Install PROJ 6.0.0 in /opt/proj using /var/tmp/build/proj as the build
# directory.

build_dir=${build_dir:-/var/tmp/build/proj}
prefix=${prefix:-/opt/proj}
sqlite_prefix=${sqlite_prefix:-/opt/sqlite}

mkdir -p ${prefix}
mkdir -p ${build_dir}
cd ${build_dir}
version=9.4.1

# --no-check-certificate is needed on ancient Ubuntu because
# ca-certificates is old
wget -nc \
     https://download.osgeo.org/proj/proj-${version}.tar.gz
rm -rf proj-${version}
tar xzf proj-${version}.tar.gz

cd proj-${version}

PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}
export PKG_CONFIG_PATH=${sqlite_prefix}/lib/pkgconfig:${PKG_CONFIG_PATH}

CC="${CC}" CXX="${CXX}" cmake \
    -B ${build_dir}/proj-${version} \
    -DCMAKE_PREFIX_PATH=${sql_prefix} \
    -S ${build_dir}/proj-${version} 

make -j 2 VERBOSE=1 -C ${build_dir}/proj-${version} 
