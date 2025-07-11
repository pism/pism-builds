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
make climber-clim

# Make sure to install the `runner` package too
pip install https://github.com/fesmc/runner/archive/refs/heads/master.zip

# Set up your `runme` config file for your system
cp .runme/runme_config .runme_config
# - Edit hpc and account name to match your settings

# Run a pre-industrial equilibrium climate-only test simulation
./runme -rs -q short --omp 32 -o output/clim
