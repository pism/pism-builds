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

for module in pandas pymc3 GPy torch netCDF4 netcdftime cftime pyproj matplotlib cdo nco SALib cf_units Unidecode pyDOE statsmodels wget gpytorch; do
    pip install $module --user
done

build_ocgis
build_pypismtools
