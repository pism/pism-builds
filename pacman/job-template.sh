#!/bin/bash
#PBS -q standard_16
#PBS -l walltime=8:00:00 
#PBS -l nodes=2:ppn=16
#PBS -j oe

cd $PBS_O_WORKDIR

# command