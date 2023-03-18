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

python=310
clang=13

$PORT -vN install \
     mpich \
     hdf5  +mpich +threadsafe \
     netcdf +mpich \
     cdo +cdi +grib_api  \
     gdal +netcdf +hdf5  \
     ncview \
     git +bash_completion +svn \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     ffmpeg +nonfree \
     py${python}-nose \
     py${python}-future \
     py${python}-black \
     py${python}-sphinx \
     py${python}-sphinx_rtd_theme \
     py${python}-jupyter \
     py${python}-jupyterlab \
     py${python}-pip \
     py${python}-autopep8 \
     py${python}-pyproj \
     py${python}-scipy \
     py${python}-shapely \
     py${python}-cython \
     py${python}-netcdf4 \
     py${python}-matplotlib \
     py${python}-seaborn \
     py${python}-statsmodels \
     py${python}-pip \
     py${python}-pandas \
     py${python}-fiona \
     py${python}-gdal \
     py${python}-scikit-learn \
     py${python}-unidecode \
     pip_select \
     py${python}-flake8 \
     py${python}-pylint \
     py${python}-xarray \
     py${python}-jupyter \
     py${python}-jupyterlab \
     py${python}-virtualenv \
     py${python}-sympy \
     py${python}-codestyle \
     py${python}-autopep8 \
     py${python}-pytest \
     py${python}-pathlib2 \
     py${python}-openpyxl \
     py${python}-tensorboard \
     py${python}-tensorboardX \
     swig-python \
     py${python}-pyqt5-webengine \
     py${python}-pyqt5 +scintilla +webkit \
     qgis3    



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
for module in braceexpand cdo nco SALib pyDOE sklearn torch torchvision torchaudio tensorboardX pytorch-lightning gpytorch cf-units cf-xarray pint-xarray; do
    python -m pip install $module --user
done


# # cfunits currently fails to build with pip.
# # compile use the flag:
# CFLAGS=-I/opt/local/include/udunits2/
