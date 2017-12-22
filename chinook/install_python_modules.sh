#!/bin/bash

build_ocgis() {
    cd $HOME
    rm -rf ocgis
    git clone git@github.com:NCPP/ocgis.git
    cd ocgis
    python setup.py install --user
}

pip install netCDF4 --user
pip install jupyter --user
pip install -Iv pygdal==2.1.0.3 --user
pip install pyproj --user
pip install matplotlib --user
pip install cdo --user
build_ocgis