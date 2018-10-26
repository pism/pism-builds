#!/bin/bash

build_ocgis() {
    cd $HOME
    rm -rf base/ocgis
    cd base
    git clone git@github.com:NCPP/ocgis.git
    cd ocgis
    python setup.py install --user
}

build_pypismtools() {
    cd $HOME
    rm -rf base/ocgis
    cd base
    git clone git@github.com:pism/pypismtools.git
    cd pypismtools
    python setup.py install --user
}

for module in netCDF4 netcdftime cftime jupyter[all] ipython[all] pyproj matplotlib cdo==1.3.2 nco SALib cf_units Unidecode pyDOE statsmodels wget PyQt5; do
    pip install $module --user
done

build_ocgis
build_pypismtools
