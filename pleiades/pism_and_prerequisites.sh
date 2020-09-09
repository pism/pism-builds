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

./udunits2.sh
./gsl.sh
./fftw3.sh
./proj.sh
./netcdf.sh
./petsc.sh

./pism.sh
