#!/bin/bash

cat > script.queue << EOF
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:model=wes
#PBS -l walltime=200
#PBS -W group_list=s1560
#PBS -m e

. /usr/share/modules/init/bash
module load comp-intel/2015.0.090
module load mpi-sgi/mpt.2.12r16

export PATH="$PATH:."
export MPI_GROUP_MAX=64
mpiexec -np 1 ./conftest-linux-64bit
EOF
