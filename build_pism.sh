#!/bin/bash

# stop on error
set -e
# print commands before executing them
set -x

LOCAL_LIB_DIR=$HOME/local-test
PISM_DIR=$HOME/pism-test

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

build_petsc() {
    cd $PETSC_DIR

    # Note: we use Intel compilers, disable Fortran, use 64-bit
    # indices, shared libraries, and no debugging.
    ./config/configure.py \
        --with-cc=icc --with-cxx=icpc --with-fc=0 \
        --with-blas-lapack-dir="/nasa/intel/Compiler/2015.0.090/composer_xe_2015.0.090/mkl/" \
        --with-mpi-lib="/nasa/sgi/mpt/2.12r16/lib/libmpi.so" \
        --with-mpi-include="/nasa/sgi/mpt/2.12r16/include" \
        --with-64-bit-indices=1 \
        --known-mpi-shared-libraries=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1

    # run conftest in an interactive job and wait for it to complete
    qsub -q devel -I -x ./conftest-$PETSC_ARCH

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_fftw3() {
    # download and build FFTW3
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://www.fftw.org/fftw-3.3.4.tar.gz
    tar xzvf fftw-3.3.4.tar.gz

    cd fftw-3.3.4
    ./configure --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_proj4() {
    # download and build PROJ.4
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    git clone --depth 1 https://github.com/OSGeo/proj.4.git

    cd proj.4
    ./autogen.sh
    ./configure --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone -b dev https://github.com/pism/pism.git .

    mkdir build
    cd build
    cmake -DPETSC_EXECUTABLE_RUNS=YES \
          -DCMAKE_FIND_ROOT_PATH=$LOCAL_LIB_DIR \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PROJ4=YES ..
          # -DPism_USE_PARALLEL_NETCDF4=YES \
    make -j2 install
}

build_proj4

build_fftw3

build_pism
