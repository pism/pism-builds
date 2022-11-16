#!/bin/bash

export SET_ENV=1
source ./build_libs.sh

# Build the Millennium study branch:
export version=v1.0-millennium-study-v2
export prefix=$LOCAL/pism-as19
export build_dir=$BUILD/pism-as19

./pism.sh | tee pism-as19.log
