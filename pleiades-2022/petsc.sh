#!/bin/bash

set -e
set -u
set -x

# Install PETSc in /opt/petsc using /var/tmp/build/petsc as the build
# directory.

MPICC=${MPICC:-mpicc}
MPICXX=${MPICXX:-mpicxx}
opt_flags=${opt_flags:--mavx2 -O3}

build_dir=${build_dir:-/var/tmp/build/petsc}
prefix=${prefix:-/opt/petsc}

mkdir -p ${build_dir}
cd ${build_dir}
version=3.16.6

wget -nc \
     https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz
rm -rf petsc-${version}
tar xzf petsc-${version}.tar.gz

cd petsc-${version}

PETSC_DIR=$PWD
PETSC_ARCH="linux-opt"

python3 ./configure \
        COPTFLAGS="${opt_flags}" \
        CXXOPTFLAGS="${opt_flags}" \
        --prefix=${prefix} \
        --with-cc="${MPICC}" \
        --with-cxx="${MPICXX}" \
        --with-fc=0 \
        --with-shared-libraries \
        --with-debugging=0 \
        --with-x=0 \
        --download-f2cblaslapack
# Note: f2cblaslapack is "good enough" for most PISM runs. Replace it
# with an optimized version when building PETSc with a direct solver
# such as MUMPS.

make all
make install

