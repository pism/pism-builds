#!/bin/bash

N=${N:-12}

prefix=${prefix:-/opt/coordinates}

mkdir -p $prefix
cp coordinates_config_chinook $prefix/config/
pushd $prefix
git clone https://github.com/fesmc/coordinates.git . || git pull

python config.py config/coordinates_config_chinook
make clean
make coord-static openmp=1 
