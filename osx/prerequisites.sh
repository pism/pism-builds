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

python=39
cc=clang11

sudo port -vN install mpich-${cc} \
     hdf5 +threadsafe +mpich +${cc} \
     netcdf +mpich +${cc} \
     cdo +mpich +${cc} +cdi \
     python${python} \
     OpenBLAS +native \
     screen \
     py${python}-flake8 \
     py${python}-flake8-pep8-naming \
     py${python}-numpy +openblas \
     py${python}-cython \
     emacs-app \
     py${python}-build \
     py${python}-openpyxl \
     py${python}-xlrd \ 
     git +bash_completion +svn \
     py${python}-black      py${python}-jupyterlab      py${python}-pip      py${python}-autopep8      py${python}-pyproj      py${python}-scipy      py${python}-nose      py${python}-simplegeneric      py${python}-future      py${python}-netcdf4 +mpich      py${python}-matplotlib      py${python}-seaborn      py${python}-statsmodels      py${python}-pip      py${python}-pandas      py${python}-xarray   py${python}-virtualenv      gdal +netcdf +hdf5 +mpich       ncview py${python}-pyqt5 +webkit qgis3 +mpich \
     



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
for module in braceexpand cdo nco SALib pyDOE sklearn torch torchvision torchaudio tensorboardX pytorch-lightning gpytorch feather cf-units cf-xarray pint-xarray; do
    python -m pip install $module --user
done


# # cfunits currently fails to build with pip.
# # compile use the flag:
# CFLAGS=-I/opt/local/include/udunits2/
