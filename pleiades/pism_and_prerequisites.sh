#!/bin/bash
# Automate building PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - run this script

# print commands before executing them
set -x
# stop on error
set -e
# stop if an environment variable is not defined
set -u

./fftw3.sh
./udunits2.sh
./proj4.sh
./petsc.sh

./pism.sh
