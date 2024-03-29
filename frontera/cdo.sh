#!/bin/bash

set -e
set -u
set -x

# Install CDO in /opt/cdo using /var/tmp/build/cdo as the build
# directory.

build_dir=${build_dir:-/var/tmp/build/cdo}
prefix=${prefix:-/opt/cdo}
sqlite_prefix=${sqlite_prefix:-/opt/cdo}

mkdir -p ${build_dir}
cd ${build_dir}

wget -nc https://code.mpimet.mpg.de/attachments/download/27654/cdo-2.1.1.tar.gz
rm -rf cdo-2.1.1
tar xzf cdo-2.1.1.tar.gz 

cd cdo-2.1.1

./configure --prefix=${prefix} --with-netcdf=$TACC_NETCDF_DIR

make -j8 all
make install
