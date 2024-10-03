#!/bin/bash

rm -rf libfyaml

git clone https://github.com/pantoniou/libfyaml.git

cd libfyaml

./bootstrap.sh

./configure --prefix=$LOCAL_LIB_DIR

make all

make install
