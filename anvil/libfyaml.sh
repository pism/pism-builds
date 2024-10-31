#!/bin/bash

rm -rf libfyaml

git clone https://github.com/pantoniou/libfyaml.git

cd libfyaml

./bootstrap.sh

./configure --prefix=$LOCAL_LIB_DIR \
	    CC="mpicc -cc=icx" \
	    CXX="mpicc -cc=icx"

make all

make install

