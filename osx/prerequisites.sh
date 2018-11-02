#!/bin/bash
# Andy Aschwanden's MacPort setup & python modules

sudo port -vN install \
     mpich \
     hdf5 +mpich +threadsafe +experimental \
     netcdf +mpich \
     cdo +cdi +grib_api +mpich \
     nco  \
     gdal +netcdf +geos +spatialite +postgresql10 \
     ncview \
     git +bash_completion +svn \
     boost -python27 +python36 +mpich \
     wget \
     emacs-app-devel \
     doxygen \
     aspell aspell-dict-en aspell-dict-de aspell-dict-de-alt \
     fondu \
     ffmpeg +nonfree \
     py36-numpy +gcc8 +openblas \
     py36-pyqt5 +webengine +webkit \
     py36-nose \
     py36-future \
     py36-sphinx \
     py36-sphinx_rtd_theme \
     py36-jupyter +qtconsole \
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
     py36-statsmodels \
     py36-pip \
     py36-pandas \
     py36-fiona \
     py36-gdal \
     py36-pyproj \
     py36-unidecode \
     qgis3

sudo port select --set autopep8 autopep8-36    
sudo port select --set ipython py36-ipython
sudo port select --set ipython3 py36-ipython
sudo port select --set pep8 pep8-36
sudo port select --set pip pip36
sudo port select --set python3 python36
sudo port select --set python python36
sudo port select --set cython cython36
sudo port select --set gcc mp-gcc8
sudo port select --set mpi mpich-mp-fortran
sudo port select --set sphinx py36-sphinx
sudo port select --set nosetests nosetests36

# Python modules
for module in black netcdftime cftime cf_units cdo nco SALib Unidecode pyDOE; do
    pip install $module --user
done
