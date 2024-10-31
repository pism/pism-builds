
#!/bin/bash

set -u
set -e
set -x

version=8.10.1
prefix=$LOCAL_LIB_DIR
rm -rf curl-${version}


wget https://curl.se/download/curl-${version}.tar.gz
tar -zxvf curl-${version}.tar.gz
cd curl-${version}


./configure --prefix=${prefix} 

make all && make install

