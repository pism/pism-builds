#!/bin/bash

# stop on error
set -e

cmake -DPETSC_EXECUTABLE_RUNS=YES \
      -DCMAKE_FIND_ROOT_PATH=$HOME/local \
      -DCMAKE_INSTALL_PREFIX=$HOME/pism \
      -DPism_USE_PARALLEL_NETCDF4=YES \
      -DPism_USE_PROJ4=YES ..
