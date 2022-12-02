#!/bin/bash

export SET_ENV=1
source ./build_libs.sh

# reset MPICC and MPICXX (otherwise PISM will be build with GCC even if we don't want that)
unset MPICC
unset MPICXX

# Build the dev branch:
export version=dev
export prefix=$LOCAL/pism-dev
export build_dir=$BUILD/pism-dev

./pism.sh | tee pism-dev.log
