#!/bin/bash

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=6

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

# stop on error
set -e
# print commands before executing them
set -x

build_petsc () {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git . || git pull

    ./configure \
            --with-mpi-dir=${MPICH_DIR} \
            --known-mpi-shared-libraries=0 \
            --with-64-bit-indices=1 \
            --with-batch=1 \
            --with-x=0 \
            --with-debugging=no \
            --with-shared-libraries=0 \
            --download-fblaslapack=yes \
            COPTFLAGS="-O3 -ffast-math -march=bdver1 -fPIC" \
            FOPTFLAGS="-O3 -ffast-math -march=bdver1 -fPIC"

    cat > conftest-pbs.sh <<EOF
#!/bin/bash
#PBS -q gpu
#PBS -l walltime=0:30:00 
#PBS -l nodes=1:ppn=16
#PBS -j oe

cd $PETSC_DIR

aprun -n 1 ./conftest-$PETSC_ARCH
EOF

    qsub ./conftest-pbs.sh

    read -p "Wait for the job to complete and press RETURN."

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_pism () {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    rm -rf ./build
    mkdir -p ./build
    cd build
    rm -f CMakeCache.txt

    export UDUNITS2_ROOT="/usr/local/pkg/udunits/udunits-2.1.24.gnu"

    cat > pism-on-fish.cmake <<EOF

# Compiler
set (CMAKE_C_COMPILER "cc" CACHE STRING "")
set (CMAKE_CXX_COMPILER "CC" CACHE STRING "")

# Disable testing for PISM's prerequisites
set (Pism_LOOK_FOR_LIBRARIES OFF CACHE BOOL "")

# Installation path
set (CMAKE_INSTALL_PREFIX "${PISM_DIR}" CACHE STRING "")

# General compilation/linking settings
set (Pism_ADD_FPIC OFF CACHE BOOL "")
set (Pism_LINK_STATICALLY ON CACHE BOOL "")

# No Proj.4 on fish.arsc.edu
set (Pism_USE_PROJ4 OFF CACHE BOOL "")
# No TAO on fish.arsc.edu, but we use PETSc that's recent enough
set (Pism_USE_TAO ON CACHE BOOL "")
# No PNetCDF on fish (alas)
set (Pism_USE_PNETCDF OFF CACHE BOOL "")

# Enable parallel NetCDF-4-based I/O.
set (Pism_USE_PARALLEL_NETCDF4 ON CACHE BOOL "")

# Set the custom GSL location
set (GSL_LIBRARIES "${GSL_ROOT}/lib/libgsl.a;${GSL_ROOT}/lib/libgslcblas.a" CACHE STRING "" FORCE)
set (GSL_INCLUDES  "${GSL_ROOT}/include" CACHE STRING "" FORCE)

# Set custom UDUNITS2 location
set (UDUNITS2_ROOT ${UDUNITS2_ROOT})
set (UDUNITS2_LIBRARIES "${UDUNITS2_ROOT}/lib/libudunits2.a;/usr/lib64/libexpat.a" CACHE STRING "" FORCE)
set (UDUNITS2_INCLUDES  "${UDUNITS2_ROOT}/include" CACHE STRING "" FORCE)

# Set PETSc location
set (PETSC_INCLUDES "${PETSC_DIR}/include;${PETSC_DIR}/${PETSC_ARCH}/include" CACHE STRING "" FORCE)
set (PETSC_LIBRARIES "${PETSC_DIR}/${PETSC_ARCH}/lib/libpetsc.a;-lX11;-lpthread;-lssl;-lcrypto;-ldl" CACHE STRING "" FORCE)

EOF

    cmake -C pism-on-fish.cmake $PISM_DIR/sources

    make -j $N install
}

build_petsc &> petsc-build-log.txt

build_pism  &> pism-build-log.txt
