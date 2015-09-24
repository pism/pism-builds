#!/bin/bash

# Automate building PROJ.4, FFTW, PETSc, and PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - download and unpack PETSc
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - edit LOCAL_LIB_DIR and PISM_DIR below
# - run this script
#
# This script uses the -x option of qsub, which runs a script in an
# interactive job, making the rest of the script wait for the
# completion of this script. (See "man qsub" for details.)

# directory to install PROJ.4 and FFTW in
LOCAL_LIB_DIR=$HOME/local-test

# PISM installation directory
PISM_DIR=$HOME/pism-test

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

# stop on error
set -e
# print commands before executing them
set -x

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

    cat > script.queue << EOF
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:model=wes
#PBS -l walltime=200
#PBS -W group_list=s1560
#PBS -m e

. /usr/share/modules/init/bash
module load comp-intel/2015.0.090
module load mpi-intel/5.0.3.048
export PATH="$PATH:."
export MPI_GROUP_MAX=64
mpiexec -np 1 ./conftest-$PETSC_ARCH
EOF

    # run conftest in an interactive job and wait for it to complete
    qsub -q devel script.queue
    read -p "Wait for the job to complete and press RETURN."

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
    ./configure --enable-shared --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_proj4() {
    # download and build PROJ.4
    mkdir -p $LOCAL_LIB_DIR/sources/proj.4
    cd $LOCAL_LIB_DIR/sources/proj.4

    git clone --depth 1 -b 4.9.2-maintenance https://github.com/OSGeo/proj.4.git . || git pull

    # remove and re-generate files created by autoconf
    autoreconf --force --install
    ./configure --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    # use Intel's MPI compiler wrappers
    export CC=mpiicc
    export CXX=mpiicpc
    cmake -DPETSC_EXECUTABLE_RUNS=YES \
          -DCMAKE_FIND_ROOT_PATH=$LOCAL_LIB_DIR \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES ..
    make -j2 install
}

build_petsc

build_proj4

build_fftw3

build_pism
