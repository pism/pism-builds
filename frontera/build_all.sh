#!/bin/bash

set -x
set -u
set -e

# Build prerequisite libraries:
./build_libs.sh

# Build PISM (the dev branch)
./build_pism-dev.sh
