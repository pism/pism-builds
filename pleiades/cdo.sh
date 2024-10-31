#!/bin/bash

set -e
set -u
set -x

# Install CDO in /opt/cdo using /var/tmp/build/cdo as the build
# directory.

build_dir=${build_dir:-/var/tmp/build/cdo}
prefix=${prefix:-/opt/cdo}

mkdir -p ${build_dir}
cd ${build_dir}

wget -nc https://code.mpimet.mpg.de/attachments/download/29649/cdo-2.4.4.tar.gz 
rm -rf cdo-2.4.4
tar xzf cdo-2.4.4.tar.gz 

cd cdo-2.4.4

CXX="$CXX -std=c++20" ./configure --prefix=${prefix} --with-netcdf=$HOME/local/netcdf/

make -j8 all
make install
