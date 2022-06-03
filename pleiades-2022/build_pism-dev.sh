#!/bin/bash

export SET_ENV=1
source ./build_libs.sh

# Build the dev branch:
export version=dev
export prefix=$LOCAL/pism-dev
export build_dir=$BUILD/pism-dev

./pism.sh | tee pism-dev.log
