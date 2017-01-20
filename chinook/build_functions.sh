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

MPI_INCLUDE="/opt/scyld/openmpi/1.10.2/intel/include"
MPI_LIBRARY="/opt/scyld/openmpi/1.10.2/intel/lib/libmpi.so"

build_hdf5() {
    # download and build HDF5
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    # 1.8 branch
    name=hdf5-1.8.18
    url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.18/src/${name}.tar.gz

    # 1.10 branch
    name=hdf5-1.10.0-patch1
    url=https://support.hdfgroup.org/ftp/HDF5/current/src/${name}.tar.gz

    wget -nc ${url}
    tar xzvf ${name}.tar.gz

    cd ${name}
    CC=mpicc ./configure --disable-shared --enable-parallel --prefix=$LOCAL_LIB_DIR/hdf5 2>&1 | tee hdf5_configure.log

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
    git checkout 4.6.0

    export CC=mpicc
    export CPPFLAGS=-I$LOCAL_LIB_DIR/include
    export LIBS="-liomp5 -lpthread"
    export LDFLAGS="-L$LOCAL_LIB_DIR/lib -L/usr/lib64"
    ./configure \
	--prefix=$LOCAL_LIB_DIR \
	--enable-netcdf-4 \
	--enable-udunits2 \
	--enable-openmp 2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log
}

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .
    # Note: we use Intel compilers, disable Fortran, use 64-bit
    # indices, shared libraries, and no debugging.
    ./config/configure.py \
        --with-cc=icc --with-cxx=icpc --with-fc=0 \
        --with-blas-lapack-dir="/usr/lib64/atlas/" \
        --with-mpi-lib=$MPI_LIBRARY \
        --with-mpi-include=$MPI_INCLUDE \
        --with-64-bit-indices=1 \
        --known-mpi-shared-libraries=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1

    # run conftest in an interactive job and wait for it to complete
    srun -n 1 -N 1 -p t2small mpirun ./conftest-$PETSC_ARCH

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_petsc4py() {
    rm -rf $HOME/petsc4py
    mkdir -p $HOME/petsc4py
    cd $HOME/petsc4py
    git clone https://bitbucket.org/petsc/petsc4py.git .
    cd $HOME/petsc4py
    python setup.py build
    python setup.py install
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
    opt="-O3 -axCORE-AVX2 -xSSE4.2 -ipo -fp-model precise"
    export CC=icc
    export CXX=icpc
    cmake -DCMAKE_CXX_FLAGS="${opt} -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="${opt} -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPETSC_EXECUTABLE_RUNS=ON \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR;$LOCAL_LIB_DIR/netcdf" \
          -DMPI_C_INCLUDE_PATH="$MPI_INCLUDE" \
          -DMPI_C_LIBRARIES="$MPI_LIBRARY" \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e
}

build_all() {
    build_nco
    build_petsc
    build_petsc4py
    build_hdf5
    build_netcdf
    build_pism
}
