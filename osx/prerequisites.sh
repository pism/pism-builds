#!/bin/bash
# Andy Aschwanden's MacPort setup & python modules
# Note:
#
# This is my personal setup which may or may not be right
# for anyone else.
# In particular I compile ports with +clang90 +mpich
# to get OpenMP capabilities in CDO


python=311
clang=15

# NCO requires ANTRL which needs Java
# https://www.oracle.com/java/technologies/downloads/#jdk20-mac

sudo port -vN install \
      mpich-clang${clang}  \
      hdf5 +clang${clang} +threadsafe +mpich\
      cdo +cdi +clang${clang} +mpich ncview \
      gsl \
      fftw-3 \
      emacs-app \
      gdal +mpich +netcdf +clang${clang} \
      nco \
      python${python} \
      py${python}-pip \
      py${python}-numpy \
      py${python}-pandas \
      py${python}-scipy \
      py${python}-arrow \
      py${python}-seaborn \
      py${python}-xarray   \
      py${python}-black \
      py${python}-virtualenv  \
      py${python}-mypy \
      py${python}-jupyterlab \
      py${python}-gdal \
      py${python}-jupyterlab \
      py${python}-autopep8 \
      py${python}-isort \
      py${python}-joblib \
      py${python}-h5netcdf \
      py${python}-openpyxl \
      py${python}-pytest \
      py${python}-jedi \
      py${python}-pylint \
      swig \
      swig-python \
      pre-commit \
      julia


export PORT="sudo port"

$PORT select --set autopep8 autopep8-${python}    
$PORT select --set flake8 flake8-${python}    
$PORT select --set pycodestyle pycodestyle-py${python}
$PORT select --set pip pip${python}
$PORT select --set pip3 pip${python}
$PORT select --set python3 python${python}
$PORT select --set python python${python}
$PORT select --set cython cython${python}
$PORT select --set mpi mpich-${cc}-fortran
$PORT select --set sphinx py${python}-sphinx
$PORT select --set nosetests nosetests${python}
$PORT select --set virtualenv virtualenv${python}
$PORT select --set py-sympy py${python}-sympy
$PORT select --set pytest pytest${python}
$PORT select --set pytest py${python}-openpyxl
$PORT select --set pylint pylint${python}
$PORT select --set black black${python}

# # Python modules
for module in pyarrow fastparquet braceexpand cdo nco SALib pyDOE pyDOE2 nc-time-axis scikit-learn torch torchvision torchaudio tensorboard tensorboardX lightning==1.9.0  cf-units cf-xarray pint-xarray; do
    python -m pip install $module --user
done


# # cfunits currently fails to build with pip.
# # compile use the flag:
# CFLAGS=-I/opt/local/include/udunits2/
