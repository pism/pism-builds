#!/bin/bash

# Automate building PETSc and PISM on chinook.
#
# To use this script,
#
# - add "source /path/to/chinook/profile" to your .bash_profile
# - add "source /path/to/common_settings" to your .bash_profile
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
