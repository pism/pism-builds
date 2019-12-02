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
     hdf5 +clang80 +mpich +threadsafe +experimental \
     netcdf +mpich \
     cdo +cdi +grib_api +mpich +clang80 \
     nco +clang80 +mpich \
     gdal +netcdf +geos +spatialite +postgresql10 +hdf5 +mpich +clang80\
     ncview \
     git +bash_completion +svn \
     boost -python27 +python37 +mpich +clang80 \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     fondu \
     ffmpeg +nonfree \
     black \ 
     py37-numpy +gcc9 +openblas \
     py37-pyqt5-webengine \
     py37-pyqt5 +webkit \
     py37-nose \
     py37-simplegeneric \
     py37-future \
     py37-sphinx \
     py37-sphinx_rtd_theme \
     py37-jupyter +qtconsole \
     py37-jupyterlab \
     py37-pip \
     py37-autopep8 \
     py37-pyproj \
     py37-scipy \
     py37-shapely \
     py37-cython \
     py37-netcdf4 +mpich \
     py37-matplotlib \
     py37-matplotlib-basemap \
     py37-unidecode \
     py37-seaborn \
     py37-statsmodels \
     py37-pip \
     py37-pandas \
     py37-fiona \
     py37-gdal \
     py37-pyproj \
     py37-unidecode \
     py37-scikit-learn \
     py37-xarray \
     qgis3 +mpich -python36 +python37


sudo port select --set autopep8 autopep8-37    
sudo port select --set ipython py37-ipython
sudo port select --set ipython3 py37-ipython
sudo port select --set pep8 pep8-37
sudo port select --set pip pip37
sudo port select --set python3 python37
sudo port select --set python python37
sudo port select --set cython cython37
sudo port select --set gcc mp-gcc9
sudo port select --set mpi mpich-mp-fortran
sudo port select --set sphinx py37-sphinx
sudo port select --set nosetests nosetests37

# Python modules
for module in braceexpand black netcdftime cftime cf-units cdo nco SALib Unidecode pyDOE Pillow palettable sphinxcontrib-bibtex sphinxcontrib-qthelp tensorflow gpflow GPy; do
    pip install $module --user
done

# cf-units currently fails to build with pip.
# compile from github source and use the flag:
CFLAGS=-I/opt/local/include/udunits2/

sudo port -vN install \
     mumps +clang80 +mpich \
     petsc +clang80 +mpich +mumps \
     armadillo  +clang80 +mpich \
     dolfin +petsc +clang80 +hdf5 \
     py37-ffc +mpich \
     py37-pkgconfig \  
     py37-dolfin

# edit the petsc portfile and add

configure.fcflags   -Os
configure.fflags    -Os -m64
