#!/bin/bash

build_ocgis() {

    git clone git@github.com:NCPP/ocgis.git
    cd ocgis
    git checkout remotes/origin/v-2.0.0.dev1
    python setup.py install --user
}

pip install netCDF4 --user
pip install jupyter --user
pip install -Iv pygdal==2.1.0.3 --user
pip install pyproj --user


build_ocgis()