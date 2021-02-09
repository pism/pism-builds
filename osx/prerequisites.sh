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

clang=90
python=38

$PORT -vN install \
     mpich-clang${clang} \
     hdf5 +clang${clang} +mpich \
     netcdf +mpich +clang${clang} \
     cdo +cdi +grib_api +mpich +clang${clang} \
     nco +mpich +clang${clang} \
     gdal +netcdf +geos +spatialite +postgresql12 +hdf5 +mpich +clang${clang} \
     ncview \
     git +bash_completion +svn \
     boost -python27 +python${python} +mpich +clang${clang} \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     fondu \
     ffmpeg +nonfree \
     gdb \
     py${python}-numpy +openblas \
     py${python}-pyqt5-webengine \
     py${python}-pyqt5 +scintilla +webkit \
     py${python}-nose \
     py${python}-simplegeneric \
     py${python}-future \
     py${python}-black \
     py${python}-sphinx \
     py${python}-sphinx_rtd_theme \
     py${python}-jupyter +qtconsole \
     py${python}-jupyterlab \
     py${python}-pip \
     py${python}-autopep8 \
     py${python}-pyproj \
     py${python}-scipy \
     py${python}-shapely \
     py${python}-cython \
     py${python}-netcdf4 +mpich +clang${clang} \
     py${python}-matplotlib \
     py${python}-matplotlib-basemap \
     py${python}-seaborn \
     py${python}-statsmodels \
     py${python}-pip \
     py${python}-pandas \
     py${python}-fiona \
     py${python}-gdal \
     py${python}-pyproj \
     py${python}-scikit-learn \
     py${python}-autopep8 \
     py${python}-unidecode \
     pip_select \
     py${python}-xarray \
     py${python}-jupyterlab \
     py${python}-virtualenv \
     py${python}-sympy \
     py${python}-codestyle \
     py${python}-autopep8 \
     py${python}-virtualenv \
     py${python}-pytest \
     py${python}-pymc3 \
     py${python}-pytorch +mpich +clang${clang} \
     swig-python \
     qgis3 +mpich -python36 +python${python} +clang${clang} \
     vtk +python${python} +mpich +clang${clang} +qt5 \


$PORT select --set autopep8 autopep8-${python}    
$PORT select --set pycodestyle pycodestyle-py${python}
$PORT select --set pip pip${python}
$PORT select --set pip3 pip${python}
$PORT select --set python3 python${python}
$PORT select --set python python${python}
$PORT select --set cython cython${python}
$PORT select --set gcc mp-gcc10
$PORT select --set mpi mpich-clang${clang}-fortran
$PORT select --set sphinx py${python}-sphinx
$PORT select --set nosetests nosetests${python}
$PORT select --set virtualenv virtualenv${python}
$PORT select --set py-sympy py${python}-sympy
$PORT select --set pytest pytest${python}
$PORT select --set pytest py${python}-openpyxl

# # Python modules
for module in braceexpand cdo nco SALib pyDOE sphinxcontrib-bibtex sphinxcontrib-qt* GPy sklearn nc-time-axis gpytorch; do
    python -m pip install $module --user
done

# # cfunits currently fails to build with pip.
# # compile from github source and use the flag:
# CFLAGS=-I/opt/local/include/udunits2/

# # This is only needed if you want dolfin
# $PORT -vN install \
#      mumps +clang${clang} +mpich \
#      petsc +clang${clang} +mpich +mumps \
#      armadillo  +clang${clang} +mpich \
#      py${python}-ffc +mpich\
#      dolfin +petsc +clang${clang} +hdf5 \
#      py${python}-pkgconfig \  
#      py${python}-dolfin

# # edit the petsc portfile and add

# configure.fcflags   -Os
# configure.fflags    -Os -m64
