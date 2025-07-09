#!/bin/bash

N=${N:-12}

prefix=${prefix:-/opt/fesm}

export FFTWSRC=fftw-3.3.10
export LISSRC=lis-2.1.6

export CONFIGURATION_FILE=""
export IFX_CONFIGURATION_FILE=""
export ICX_CONFIGURATION_FILE=""
export ICX_NO_DEFAULT_CONFIG=1

rm -rf $prefix
mkdir -p $prefix
SCRIPTDIR=$PWD
pushd $prefix
git clone https://github.com/fesmc/fesm-utils.git . || git pull
cp ${SCRIPTDIR}/fesm_utils_install_chinook install_chinook
cp ${SCRIPTDIR}/autoreconf.patch ${LISSRC}/autoreconf.patch
cp ${SCRIPTDIR}/fesm_utils_config_chinook utils/config/

./install_chinook ifx

exit

cd utils
python config.py config/fesm_utils_config_chinook
make clean
make fesmutils-static
