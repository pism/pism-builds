
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


MPI_INCLUDE="/nasa/sgi/mpt/2.15r20/include"
MPI_LIBRARY="/nasa/sgi/mpt/2.15r20/lib/libmpi.so"

# stop on error
set -e
# print commands before executing them
set -x

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

build_nco() {
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources
    rm -rf nco
    git clone https://github.com/nco/nco.git
    cd nco
    git checkout 4.6.7

    NETCDF_ROOT=/nasa/netcdf/4.4.1.1_mpt ANTLR_ROOT=/nasa/sles11/nco/4.6.2/gcc/mpt UDUNITS2_PATH=$LOCAL_LIB_DIR ./configure \
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

build_ncview(){


    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    wget -nc ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.7.tar.gz
    tar -zxvf ncview-2.1.7.tar.gz
    cd ncview-2.1.7
    cat > libpng.patch <<EOF
--- configure   2016-03-21 09:52:34.000000000 -0700
+++ configure_new       2017-06-16 14:58:37.187912859 -0700
@@ -5504,7 +5504,7 @@
        echo "** Could not find the png.h file, so -frames support will not be included  **"
        echo "** Install the PNG library (and development headers) to fix this           **"
 fi
-PNG_LIBNAME=libpng.so
+PNG_LIBNAME=libpng16.so

 # Check whether --with-png_libdir was given.
 if test "${with_png_libdir+set}" = set; then :
EOF

    patch < libpng.patch

    CC=mpicc CFLAGS='-g' CPPFLAGS=-I$LOCAL_LIB_DIR/include LDFLAGS=-L$LOCAL_LIB_DIR/lib LIBS='-L$LOCAL_LIB_DIR/lib -lpng -Bstatic -ludunits2 -Bdynamic' ./configure \
	--prefix=${LOCAL_LIB_DIR} \
	--with-nc-config=/nasa/netcdf/4.4.1.1_mpt/bin/nc-config \
	--with-png_incdir=/nasa/pkgsrc/sles12/2016Q4/include \
	--with-png_libdir=/nasa/pkgsrc/sles12/2016Q4/lib 2>&1 | tee ncview_configure.log

    make -j $N 2>&1 | tee ncview_compile.log
    make install 2>&1 | tee ncview_install.log
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

    git clone --depth 1 -b thk_calving https://github.com/pism/pism.git . || git pull

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
          -DCMAKE_CXX_FLAGS="-std=c++11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006,2102 -lhdf5" \
          -DCMAKE_C_FLAGS="-std=c11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006 -lhdf5" \
	  -LINK_LIBRARIES="-lhdf5" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j4 install
}

T="$(date +%s)"

#build_petsc
#build_proj4
#build_udunits2
build_pism
#build_nco
#build_cdo
#build_ncview

T="$(($(date +%s)-T))"
echo "Time in seconds: ${T}"

printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
