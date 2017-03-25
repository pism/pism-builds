#!/bin/bash

build_ocgis() {

    git clone git@github.com:NCPP/ocgis.git
    cd ocgis
    python setup.py install --user
}

pip install netCDF4 --user
pip install jupyter --user
pip install pygdal --user
build_ocgis()