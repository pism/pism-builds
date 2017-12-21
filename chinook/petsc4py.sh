#!/bin/bash

set -u
set -e
set -x

build_petsc4py() {
    rm -rf $HOME/petsc4py
    mkdir -p $HOME/petsc4py
    cd $HOME/petsc4py
    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc4py.git .
    cd $HOME/petsc4py
    python setup.py build
    python setup.py install --user
}

build_petsc4py
