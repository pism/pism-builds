
# Automate building PROJ.4, FFTW, PETSc, and PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - edit LOCAL_LIB_DIR and PISM_DIR below
# - run this script

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=8

export PETSC_DIR=$HOME/petsc

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

export MPICC_CC=icc
export MPICXX_CXX=icpc
#export CC=mpicc

# MPI_ROOT is set by the module system
MPI_INCLUDE="${MPI_ROOT}/include"
MPI_LIBRARY="${MPI_ROOT}/lib/libmpi.so"

# stop on error
set -e
# print commands before executing them
set -x

build_hdf5() {
    # download and build HDF5 
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    rm -rf hdf5
    git clone -b hdf5_1_8_18 --depth 1 https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git
    cd hdf5
    #export CFLAGS='-xHost -ip'
    #export CXXFLAGS='-xHost -ip'
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
    #export CFLAGS='-xHost -ip -no-prec-div -static-intel'
    #export CXXFLAGS='-xHost -ip -no-prec-div -static-intel'
    #export CPP='icc -E'
    #export CXXCPP='icpc -E'
    export CFLAGS='-g'
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5/lib
    CC=mpicc ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}


build_udunits2() {
    # download and build udunits2           
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    version=2.2.25
    wget -nc ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-${version}.tar.gz
    tar -zxvf udunits-${version}.tar.gz
    cd udunits-${version}

    CC=gcc ./configure --prefix=$LOCAL_LIB_DIR 2>&1 | tee udunits_configure.log

    make all -j $N 2>&1 | tee udunits_make.log
    make install 2>&1 | tee udunits_install.log
}

build_cdo(){

    build_zlib

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc --no-check-certificate https://code.zmaw.de/attachments/download/14686/cdo-1.8.2.tar.gz
    tar -zxvf cdo-1.8.2.tar.gz
    cd cdo-1.8.2

    CC=$MPICC_CC LIBS="-lmpi" ./configure \
        --prefix=$LOCAL_LIB_DIR \
	--with-netcdf=/nasa/netcdf/4.4.1.1_mpt \
	--with-hdf5=/nasa/hdf5/1.8.18_mpt \
	--with-zlib=$LOCAL_LIB_DIR \
	--with-proj=$LOCAL_LIB_DIR 2>&1 | tee cdo_configure.log

    make -j $N 2>&1 | tee cdo_compile.log
    make install 2>&1 | tee cdo_install.log
}

build_zlib() {

    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc http://zlib.net/zlib-1.2.11.tar.gz
    tar -zxvf zlib-1.2.11.tar.gz
    cd zlib-1.2.11

    ./configure --prefix=${LOCAL_LIB_DIR} 2>&1 | tee zlib_configure.log

    make -j $N 2>&1 | tee zlib_compile.log
    make install 2>&1 | tee zlib_install.log
}

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git .
    # Note: we use Intel compilers, disable Fortran, use 64-bit
    # indices, shared libraries, and no debugging.
    ./config/configure.py \
	--with-mpi-dir=/nasa/sgi/mpt/2.15r20 \
	--with-blas-lapack-dir=/nasa/intel/Compiler/2016.2.181/mkl/lib/intel64 \
	--with-cpp=/usr/bin/cpp \
	--with-gnu-compilers=0 \
	--known-mpi-shared-libraries=1 \
	--with-vendor-compilers=intel \
	-COPTFLAGS=-g -O3 -axCORE-AVX2,AVX -xSSE4.2 -CXXOPTFLAGS=-g -O3 -axCORE-AVX2,AVX -xSSE4.2 -FOPTFLAGS=-g -O3 -axCORE-AVX2,AVX -xSSE4.2 \
        --with-fc=0 \
        --with-64-bit-indices=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1

    cat > script.queue << EOF
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:model=bro:aoe=sles12
#PBS -l walltime=200
#PBS -W group_list=s1560
#PBS -m e

. /usr/share/modules/init/bash
module purge
module load comp-intel/2016.2.181
module load mpi-sgi/mpt
#module load mpi-intel/5.0.3.048
export PATH="$PATH:."
export MPI_GROUP_MAX=64
mpiexec -np 1 ./conftest-$PETSC_ARCH
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
	  -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR" \
          -DCMAKE_CXX_FLAGS="-std=c++11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="-std=c11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR/hdf5;$LOCAL_LIB_DIR/netcdf" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j4 install
}

T="$(date +%s)"

build_all() {
#build_petsc
#build_proj4
#build_udunits2
build_pism
#build_cdo
#build_ncview
}

T="$(($(date +%s)-T))"
echo "Time in seconds: ${T}"

printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
