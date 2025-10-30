#!/bin/bash

set -e
set -u
set -x

N=${N:-12}

# Installation prefix and build location:
prefix=${prefix:-/opt/yelmo}

SCRIPTDIR=$PWD
mkdir -p ${prefix}
pushd ${prefix}
git clone https://github.com/palma-ice/yelmo.git . || (git checkout climber-x && git pull)
cp ${SCRIPTDIR}/yelmo_config_chinook $prefix/config/
python config.py config/yelmo_config_chinook
make clean
# -j $N does not work here
make yelmo-static
