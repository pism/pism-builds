#!/bin/bash

conda create --name pism
source activate pism
#conda install -c conda-forge cmake gsl udunits2 proj openmpi-mpicc openmpi-mpicxx lapack fftw petsc petsc4py ncview nco cdo nose doxygen tbb=2020.2
conda install -c conda-forge gdal cmake gsl udunits2 proj openmpi-mpicc openmpi-mpicxx lapack fftw ncview nco cdo nose doxygen tbb=2020.2
