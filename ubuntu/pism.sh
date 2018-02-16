#!/bin/bash

set -e
set -x

branch=${1}

prefix=${HOME}/local/
pism_source_dir=${HOME}/github/pism/pism
pism_build_dir=${prefix}/build/pism${branch}/
N=4

configure_pism() {
    rm -rf ${pism_build_dir}
    mkdir -p ${pism_build_dir}
    cd ${pism_build_dir}

    export PETSC_DIR=~/local/petsc/petsc-3.8.0/
    export PETSC_ARCH=opt-32bit

    CC=mpicc CXX=mpicxx cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_FIND_ROOT_PATH="${prefix}/hdf5;${prefix}/netcdf;${prefix}/pnetcdf" \
        -DCMAKE_INSTALL_PREFIX=${prefix}/pism \
        -DPism_LOOK_FOR_LIBRARIES=YES \
        -DPism_USE_PROJ4=YES \
        ${pism_source_dir}
}

configure_pism
