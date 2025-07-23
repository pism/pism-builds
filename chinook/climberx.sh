#!/bin/bash

set -e
set -u
set -x

N=${N:-12}

# Installation prefix and build location:
prefix=${prefix:-/opt/climber-x}

SCRIPTDIR=$PWD
pushd ${prefix}
git clone https://github.com/cxesmc/climber-x.git . || git pull
cp ${SCRIPTDIR}/climberx_config_chinook $prefix/config/
python config.py config/climberx_config_chinook
# Clone input file directory
mkdir -p input
pushd input
git clone https://gitlab.pik-potsdam.de/cxesmc/climber-x-input.git . || git pull
cd ..

# Compile the climate model 
make clean
make climber-clim-ice
