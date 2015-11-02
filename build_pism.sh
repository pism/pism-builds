#!/bin/bash

# Automate building PROJ.4, FFTW, PETSc, and PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - download and unpack PETSc
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - edit LOCAL_LIB_DIR and PISM_DIR below
# - run this script

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=8

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

#MPI_INCLUDE="/nasa/sgi/mpt/2.12r16/include"
#MPI_LIBRARY="/nasa/sgi/mpt/2.12r16/lib/libmpi.so"
MPI_INCLUDE="/nasa/intel/impi/5.0.3.048/intel64/include"
MPI_LIBRARY="/nasa/intel/impi/5.0.3.048/intel64/lib/libmpi.so"
# stop on error
set -e
# print commands before executing them
set -x

build_hdf5() {
    # download and build HDF5 
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.15-patch1.tar
    tar -xvf hdf5-1.8.15-patch1.tar

    cd hdf5-1.8.15-patch1
    CC=mpicc CFLAGS=-g ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR

    make all -j $N
    make install
}

build_netcdf() {
    # download and build netcdf                                                                                            
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.1.tar.gz
    tar -zxvf netcdf-4.3.3.1.tar.gz

    cd netcdf-4.3.3.1
    CC=mpicc CFLAGS=-g CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib ./configure \
	--enable-netcdf4 \
	--disable-dap \
	--prefix=$LOCAL_LIB_DIR 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco
    git checkout 4.5.2

    CC=mpicc CFLAGS=-g CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib ./configure \
	--prefix=$LOCAL_LIB_DIR \
	--enable-netcdf-4 \
	--enable-udunits2 \
	--enable-openmp 2>&1 | tee nco_configure.log

    make -j $N  2>&1 | tee nco_compile.log
    make install  2>&1 | tee nco_install.log

}

build_cdo(){

    build_zlib

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc https://code.zmaw.de/attachments/download/11392/cdo-1.7.0.tar.gz
    tar -zxvf cdo-1.7.0.tar.gz
    cd cdo-1.7.0

    CC=mpicc CFLAGS='-g' CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-netdf=$LOCAL_LIB_DIR \
	--with-hdf5=$LOCAL_LIB_DIR \
	--with-zlib=$LOCAL_LIB_DIR \
	--disable-openmp \
	--with-proj=$LOCAL_LIB_DIR 2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_zlib() {

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://zlib.net/zlib-1.2.8.tar.gz
    tar -zxvf zlib-1.2.8.tar.gz
    cd zlib-1.2.8

    ./configure --prefix=${LOCAL_LIB_DIR} 2>&1 | tee zlib_configure.log

    make -j $N 2>&1 | tee zlib_compile.log
    make install 2>&1 | tee zlib_install.log
}

build_ncview(){

    build_png

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.6.tar.gz
    tar -zxvf ncview-2.1.6.tar.gz
    cd ncview-2.1.6

    CC=mpicc CFLAGS='-g' CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib ./configure \
	--prefix=${LOCAL_LIB_DIR} \
	--with-nc-config=${LOCAL_LIB_DIR}/bin/nc-config \
	--with-png_incdir=${LOCAL_LIB_DIR}/include \
	--with-png_libdir=${LOCAL_LIB_DIR}/lib 2>&1 | tee ncview_configure.log

    make -j $N 2>&1 | tee ncview_compile.log
    make install 2>&1 | tee ncview_install.log
}

build_png() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.18.tar.gz
    tar -zxvf libpng-1.6.18.tar.gz
    cd libpng-1.6.18

    CC=mpicc ./configure \
        --prefix=${LOCAL_LIB_DIR}  2>&1 | tee png_configure.log

    make -j $N 2>&1 | tee png_compile.log
    make install 2>&1 | tee png_install.log

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
        --with-blas-lapack-dir="/nasa/intel/Compiler/2015.0.090/composer_xe_2015.0.090/mkl/" \
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

    cat > script.queue << EOF
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:model=wes
#PBS -l walltime=200
#PBS -W group_list=s1560
#PBS -m e

. /usr/share/modules/init/bash
module load comp-intel/2015.0.090
#module load mpi-sgi/mpt.2.12r16 
module load mpi-intel/5.0.3.048 
export PATH="$PATH:."
export MPI_GROUP_MAX=64
mpiexec.hydra -np 1 ./conftest-$PETSC_ARCH
EOF

    # run conftest in an interactive job and wait for it to complete
    qsub -q devel script.queue
    read -p "Wait for the job to complete and press RETURN."

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_fftw3() {
    # download and build FFTW3
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://www.fftw.org/fftw-3.3.4.tar.gz
    tar xzvf fftw-3.3.4.tar.gz

    cd fftw-3.3.4
    ./configure --enable-shared --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_proj4() {
    # download and build PROJ.4
    mkdir -p $LOCAL_LIB_DIR/sources/proj.4
    cd $LOCAL_LIB_DIR/sources/proj.4

    git clone --depth 1 -b 4.9.2-maintenance https://github.com/OSGeo/proj.4.git . || git pull

    # remove and re-generate files created by autoconf
    autoreconf --force --install
    ./configure --prefix=$LOCAL_LIB_DIR

    make all
    make install
}

build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    # use Intel's MPI compiler wrappers
    export CC=icc
    export CXX=icpc
    cmake -DMPI_C_INCLUDE_PATH=$MPI_INCLUDE \
          -DMPI_C_LIBRARIES=$MPI_LIBRARY \
          -DPETSC_EXECUTABLE_RUNS=YES \
          -DCMAKE_CXX_FLAGS="-O3 -ipo -axCORE-AVX2 -xSSE4.2" \
          -DCMAKE_C_FLAGS="-O3 -ipo -axCORE-AVX2 -xSSE4.2" \
          -DCMAKE_FIND_ROOT_PATH=$LOCAL_LIB_DIR \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
	  -DCMAKE_FIND_ROOT_PATH=$LOCAL_LIB_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources 
    make -j2 install
}

T="$(date +%s)"

build_hdf5

build_netcdf

build_petsc

build_proj4

build_fftw3

build_pism

build_nco

build_cdo

build_ncview

T="$(($(date +%s)-T))"
echo "Time in seconds: ${T}"

printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))""