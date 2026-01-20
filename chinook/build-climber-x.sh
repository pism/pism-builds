#!/bin/bash

set -x
set -u
set -e

# Build prerequisite libraries

# Run as "SET_ENV=1 ./build_libs.sh" to set environment variables
# needed to build PISM *without* actually re-building libraries.
if [ -v SET_ENV ]; then
    SET_ENV=true
else
    SET_ENV=false
fi

export N=20
export LOCAL=$LOCAL_LIB_DIR
export BUILD=$LOCAL_LIB_DIR/build/

export FC=ifx
export F77=ifx
export CC=icx
export openmp=1

export NETCDFC_ROOT=$EBROOTNETCDFMINCPLUSPLUS4
export NETCDFFI_ROOT=$EBROOTNETCDFMINFORTRAN

export CLIMBER_DIR=$LOCAL/climber-x
mkdir -p $CLIMBER_DIR

export prefix=$LOCAL/coordinates
${SET_ENV} || ./coordinates.sh | tee coordinates.log
export coordinates_prefix=$LOCAL/coordinates

export COORDROOT=${coordinates_prefix}

export prefix=$LOCAL/fesm-utils
${SET_ENV} || ./fesm.sh | tee fesm.log
export fesm_prefix=$LOCAL/fesm-utils

export FESMUTILSROOT=${fesm_prefix}

export prefix=$LOCAL/yelmo
${SET_ENV} || ./yelmo.sh | tee yelmo.log
export yelmo_prefix=$LOCAL/yelmo

export prefix=$LOCAL/vilma
${SET_ENV} || ./vilma.sh | tee vilma.log
export vilma_prefix=$LOCAL/vilma

export VILMAROOT=${vilma_prefix}
export YELMOROOT=${yelmo_prefix}

export prefix=$CLIMBER_DIR
${SET_ENV} || ./climberx.sh | tee climberx.log

pip install https://github.com/cxesmc/runner/archive/refs/heads/master.zip
