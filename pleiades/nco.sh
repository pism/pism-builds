#!/bin/bash

set -x
set -e
set -u

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# No. of cores for make
N=1

build_antlr2(){
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    wget -nc https://github.com/nco/antlr2/archive/refs/tags/antlr2-2.7.7-1.tar.gz
    tar -zxvf antlr2-2.7.7-1.tar.gz
    cd antlr2-antlr2-2.7.7-1 

    ./configure \
        --prefix=$LOCAL_LIB_DIR 2>&1 | tee antlr_configure.log}

    make -j $N  2>&1 | tee antrl_compile.log
    make install  2>&1 | tee antlr_install.log
}

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco/cmake

    export NETCDF_ROOT=$LOCAL_LIB_DIR/netcdf
    export ANTLR_ROOT=$LOCAL_LIB_DIR
    #export UDUNITS2_PATH=$LOCAL_LIB_DIR
    cmake .. \
	-DCMAKE_INSTALL_PREFIX=$LOCAL_LIB_DIR \
	-DHDF5_HL_LIBRARY=${hdf5_prefix}/lib/libhdf5_hl.so \
        -DHDF5_LIBRARY=${hdf5_prefix}/lib/libhdf5.so \
        -DNETCDF_INCLUDE=${netcdf_prefix}/include \
	-DNETCDF_LIBRARY=${netcdf_prefix}/lib/libnetcdf.so \
	-DPATH_TO_NCGEN=${netcdf_prefix}/bin/ncgen \
	-DUDUNITS_INCLUDE=/nasa/pkgsrc/toss4/2022Q1-rome/include \
	-DUDUNITS_LIBRARY=/nasa/pkgsrc/toss4/2022Q1-rome/lib/libudunits2.so \

	2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log
}

build_antlr2
build_nco
