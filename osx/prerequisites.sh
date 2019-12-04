#!/bin/bash
# Andy Aschwanden's MacPort setup & python modules
# Note:
#
# This is my personal setup which may or may not be right
# for anyone else.
# In particular I compile ports with +clang90 +mpich
# to get OpenMP capabilities in CDO

sudo port -vN install \
     mpich \
     gcc9 \
     hdf5 +clang90 +mpich +threadsafe +experimental \
     netcdf +mpich \
     cdo +cdi +grib_api +mpich \
     nco \
     gdal +netcdf +geos +spatialite +postgresql10 +hdf5 +mpich +clang90\
     ncview \
     git +bash_completion +svn \
     boost -python27 +python37 +mpich +clang90 \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     fondu \
     ffmpeg +nonfree \
     black \ 
     py38-numpy +gcc9 +openblas \
     py38-pyqt5-webengine \
     py38-pyqt5 +webkit \
     py38-nose \
     py38-simplegeneric \
     py38-future \
     py38-sphinx \
     py38-sphinx_rtd_theme \
     py38-jupyter +qtconsole \
     py38-jupyterlab \
     py38-pip \
     py38-autopep8 \
     py38-pyproj \
     py38-scipy \
     py38-shapely \
     py38-cython \
     py38-netcdf4 +mpich \
     py38-matplotlib \
     py38-matplotlib-basemap \
     py38-unidecode \
     py38-seaborn \
     py38-statsmodels \
     py38-pip \
     py38-pandas \
     py38-fiona \
     py38-gdal \
     py38-pyproj \
     py38-unidecode \
     py38-scikit-learn \
     py38-autopep8 \
     pip_select \ 
     py38-xarray \
     py38-pip \
     py38-jupyterlab \
     py38-virtualenv \
     qgis3 +mpich -python36 +python38 -grass


sudo port select --set autopep8 autopep8-38    
sudo port select --set pycodestyle pycodestyle-py38
sudo port select --set pip pip38
sudo port select --set pip3 pip38
sudo port select --set python3 python38
sudo port select --set python python38
sudo port select --set cython cython38
sudo port select --set gcc mp-gcc9
sudo port select --set mpi mpich-mp-fortran
sudo port select --set sphinx py38-sphinx
sudo port select --set nosetests nosetests38
sudo port select --set virtualenv virtualenv38
sudo port select --set py-sympy py38-sympy

# Python modules
for module in braceexpand black netcdftime cftime cf-units cdo nco SALib Unidecode pyDOE Pillow palettable sphinxcontrib-bibtex sphinxcontrib-qthelp tensorflow gpflow GPy; do
    pip install $module --user
done

# cf-units currently fails to build with pip.
# compile from github source and use the flag:
CFLAGS=-I/opt/local/include/udunits2/

sudo port -vN install \
     mumps +clang90 +mpich \
     petsc +clang90 +mpich +mumps \
     armadillo  +clang90 +mpich \
     py38-ffc +mpich \
     dolfin +petsc +clang90 +hdf5 \
     py38-pkgconfig \  
     py38-dolfin

# edit the petsc portfile and add

configure.fcflags   -Os
configure.fflags    -Os -m64
