#!/bin/bash

conda create --name pism
source activate pism
conda install -c conda-forge cmake  gsl udunits2 proj openmpi-mpicc openmpi-mpicxx lapack fftw petsc petsc4py clang nco cdo nose doxygen
