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
cp ${SCRIPTDIR}/fesm_utils_install_stampede3 install_stampede3
cp ${SCRIPTDIR}/fesm_utils_config_stampede3 utils/config/

./install_stampede3 ifx

cd utils
python config.py config/fesm_utils_config_stampede3
make clean
make -j $N fesmutils-static
make -j $N test
