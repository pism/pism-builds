#!/bin/bash

export SET_ENV=1
source ./build_libs.sh

# Build the dev branch:
export version=dev
export prefix=$LOCAL/pism
export build_dir=$BUILD/pism

./pism.sh | tee pism.log
