#!/bin/bash

# Automate building PETSc and PISM on chinook.
#
# To use this script,
#
# - add "source /path/to/chinook/profile" to your .bash_profile
# - add "source /path/to/common_settings" to your .bash_profile
# - run this script

# No. of cores for make
N=8

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

MKL=/usr/local/pkg/numlib/imkl/11.3.3.210-pic-iompi-2016b/mkl/lib/intel64
optimization_flags="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"

build_hdf5() {
    # download and build HDF5
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    # We use 1.8.15 because newer version seg fault with Intel 2016 Compilers
    name=hdf5-1.8.15
    url=https://support.hdfgroup.org/ftp/HDF5/releases/${name}/src/${name}.tar.gz

    wget -nc ${url}
    tar xzvf ${name}.tar.gz

    cd ${name}
    CC=mpicc ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR/hdf5 2>&1 | tee hdf5_configure.log

    make all -j $N 2>&1 | tee hdf5_compile.log
    make install 2>&1 | tee hdf5_install.log
}

build_netcdf() {
    # download and build netcdf

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    version=4.4.1.1
    url=ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-${version}.tar.gz

    wget -nc ${url}
    tar -zxvf netcdf-${version}.tar.gz

    cd netcdf-${version}
    export CC=$LOCAL_LIB_DIR/hdf5/bin/h5pcc
    export CC=mpicc
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5/lib
    ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco
    git checkout 4.6.5

    export CC=mpicc
    export CPPFLAGS=-I$LOCAL_LIB_DIR/netcdf/include
    opt="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"
    #export LIBS="-liomp5 -lpthread"
    export LDFLAGS="-L$LOCAL_LIB_DIR/netcdf/lib -L/usr/lib64"
    ./configure \
	--prefix=$LOCAL_LIB_DIR \
	--enable-netcdf-4 \
	--enable-udunits2 \
	--enable-openmp 2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log
}

build_cdo(){

    #build_zlib

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc https://code.zmaw.de/attachments/download/14271/cdo-1.8.1.tar.gz
    tar -zxvf cdo-1.8.1.tar.gz
    cd cdo-1.8.1

    CC=mpicc ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-hdf5=/usr/local/pkg/data/HDF5/1.8.15-pic-intel-2016b \
	--with-netcdf=/usr/local/pkg/data/netCDF/4.4.1.1-pic-intel-2016b \
        --with-proj=/usr/local/pkg/lib/PROJ/4.9.2-pic-intel-2016b \
        --with-udunits2=/usr/local/pkg/phys/UDUNITS/2.2.20-pic-intel-2016b \
        #--with-zlib=$LOCAL_LIB_DIR \
        2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .

    # Note that on Chinook mpicc and mpicxx wrap Intel's C and C++ compilers
    ./config/configure.py \
	--with-cc=mpicc \
	--with-cxx=mpicxx \
	--with-fc=0 \
	--CFLAGS="${optimization_flags}" \
	--known-mpi-shared-libraries=1 \
	--with-blas-lapack-dir=${MKL} \
	--with-64-bit-indices=1 \
	--with-debugging=0 \
	--with-valgrind=0 \
	--with-x=0 \
	--with-ssl=0 \
	--with-batch=1 \
	--with-shared-libraries=1

    # run conftest in an interactive job and wait for it to complete
    srun -t 20 -n 1 -N 1 -p debug mpirun ./conftest-$PETSC_ARCH

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_petsc4py() {
    rm -rf $HOME/petsc4py
    mkdir -p $HOME/petsc4py
    cd $HOME/petsc4py
    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc4py.git .
    cd $HOME/petsc4py
    python setup.py build
    python setup.py install --user
}

build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    rm -rf build
    mkdir -p build
    cd build

    # use Intel's C and C++ compilers
    export CC=mpicc
    export CXX=mpicxx
    cmake -DCMAKE_CXX_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="${optimization_flags} -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPETSC_EXECUTABLE_RUNS=ON \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e
}

build_all() {
    build_petsc
    #build_petsc4py
    build_pism
    # build_cdo
}
