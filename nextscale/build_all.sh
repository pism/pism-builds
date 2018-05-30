#!/bin/bash

# Automate building PETSc and PISM on PIK IBM NeXtScale.
#
# To use this script,
source profile
# - add "source /path/to/nextscale/profile" to your .bash_profile
# - run this script

source ./build_functions.sh

# stop on error
set -e
# print commands before executing them
set -x

T="$(date +%s)"
build_all
T="$(($(date +%s)-T))"

echo "Time in seconds: ${T}"
printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
