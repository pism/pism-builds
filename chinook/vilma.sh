#!/bin/bash

set -e
set -u
set -x

N=${N:-12}

# Installation prefix and build location:
prefix=${prefix:-/opt/vilma}

SCRIPTDIR=$PWD
mkdir -p ${prefix}
pushd ${prefix}
git clone git@github.com:cxesmc/vilma.git . || git pull


