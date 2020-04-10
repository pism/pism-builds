#!/bin/bash
# Andy Aschwanden's MacPort setup & python modules
# Note:
#
# This is my personal setup which may or may not be right
# for anyone else.
# In particular I compile ports with +clang90 +mpich
# to get OpenMP capabilities in CDO

if [ -z "$PORT" ] ; then
    PORT='sudo port'
fi

$PORT -vN install \
     mpich \
     gcc9 \
     hdf5 +clang90 +mpich +threadsafe +experimental \
     netcdf +mpich \
     cdo +cdi +grib_api +mpich  \
     nco \
     gdal +netcdf +geos +spatialite +postgresql10 +hdf5 +mpich +clang90\
     ncview \
     git +bash_completion +svn \
     boost -python27 +python36 +mpich +clang90 \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     fondu \
     ffmpeg +nonfree \
     black \
     gdb \
     py36-numpy +gcc9 +openblas \
     py36-pyqt5-webengine \
     py36-pyqt5 +scintilla +webkit \
     py36-nose \
     py36-simplegeneric \
     py36-future \
     py36-sphinx \
     py36-sphinx_rtd_theme \
     py36-jupyter +qtconsole \
     py36-jupyterlab \
     py36-pip \
     py36-autopep8 \
     py36-pyproj \
     py36-scipy \
     py36-shapely \
     py36-cython \
     py36-netcdf4 +mpich \
     py36-matplotlib \
     py36-matplotlib-basemap \
     py36-unidecode \
     py36-seaborn \
     py36-statsmodels \
     py36-pip \
     py36-pandas \
     py36-fiona \
     py36-gdal \
     py36-pyproj \
     py36-unidecode \
     py36-scikit-learn \
     py36-autopep8 \
     pip_select \ 
     py36-xarray \
     py36-pip \
     py36-jupyterlab \
     py36-virtualenv \
     py36-sympy \
     py36-codestyle \
     py36-autopep8 \
     py36-virtualenv \
     grass7 -python38 +python36 \
     qgis3 +mpich +grass


$PORT select --set autopep8 autopep8-36    
$PORT select --set pycodestyle pycodestyle-py36
$PORT select --set pip pip36
$PORT select --set pip3 pip36
$PORT select --set python3 python36
$PORT select --set python python36
$PORT select --set cython cython36
$PORT select --set gcc mp-gcc9
$PORT select --set mpi mpich-mp-fortran
$PORT select --set sphinx py36-sphinx
$PORT select --set nosetests nosetests36
$PORT select --set virtualenv virtualenv36
$PORT select --set py-sympy py36-sympy


# Python modules
for module in braceexpand black netcdftime cftime cdo nco SALib Unidecode pyDOE Pillow palettable sphinxcontrib-bibtex sphinxcontrib-qthel GPy sklearn eofs xarray; do
    python -m pip install $module --user
done

# cfunits currently fails to build with pip.
# compile from github source and use the flag:
CFLAGS=-I/opt/local/include/udunits2/

# This is only needed if you want dolfin
$PORT -vN install \

     mumps +clang90 +mpich \
     petsc +clang90 +mpich +mumps \
     armadillo  +clang90 +mpich \
     py36-ffc \
     dolfin +petsc +clang90 +hdf5 \
     py36-pkgconfig \  
     py36-dolfin

# edit the petsc portfile and add

configure.fcflags   -Os
configure.fflags    -Os -m64
