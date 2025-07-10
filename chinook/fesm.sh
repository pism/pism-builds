#!/bin/bash

N=${N:-12}

prefix=${prefix:-/opt/fesm}

export FFTWSRC=fftw-3.3.10
export LISSRC=lis-2.1.6

export CONFIGURATION_FILE=""
export IFX_CONFIGURATION_FILE=""
export ICX_CONFIGURATION_FILE=""
export ICX_NO_DEFAULT_CONFIG=1

mkdir -p $prefix
SCRIPTDIR=$PWD
pushd $prefix
git clone https://github.com/fesmc/fesm-utils.git . || (git checkout main && git pull)
cp ${SCRIPTDIR}/fesm_utils_install_chinook install_chinook
cp ${SCRIPTDIR}/fesm_utils_config_chinook utils/config/

# ./install_chinook ifx

cd utils
export openmp=1
python config.py config/fesm_utils_config_chinook
make clean
make -j $N fesmutils-static
make -j $N test
