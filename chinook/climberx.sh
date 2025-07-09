#!/bin/bash

set -e
set -u
set -x

N=${N:-12}

# Installation prefix and build location:
prefix=${prefix:-/opt/climber-x}

cp climberx_config_chinook $prefix/config/
pushd ${prefix}
git clone https://github.com/cxesmc/climber-x.git . || git pull
python config.py config/climberx_config_chinook
# Clone input file directory
mkdir -p input
pushd input
git clone https://gitlab.pik-potsdam.de/cxesmc/climber-x-input.git . || git pull
cd ..
mkdir -p utils
cd utils
ln -sf $fesm_prefix ./
cd ..
ls

# Compile the climate model 
make clean
make climber-clim

# Set up your `runme` config file for your system
cp .runme/runme_config .runme_config
# - Edit hpc and account name to match your settings

# Make sure to install the `runner` package too
pip install https://github.com/cxesmc/runner/archive/refs/heads/master.zip

# Run a pre-industrial equilibrium climate-only test simulation
./runme -rs -q short --omp 32 -o output/clim
