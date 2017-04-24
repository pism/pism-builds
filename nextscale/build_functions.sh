#!/bin/bash

# Automate building PETSc and PISM on PIK IBM NeXtScale.
# Following the build script by Andy Aschwanden (UAF)
#
# To use this script,
#
# - add "source /path/to/nextscale/profile" to your .bash_profile
# - run this script

# No. of cores for make
N=2

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

MPI_INCLUDE="${I_MPI_ROOT}/include64"
MPI_LIBRARY="${I_MPI_ROOT}/lib64/libmpi.so"
MPI_DIR="${I_MPI_ROOT}/intel64"


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
    CC=$CC ./configure --enable-parallel --prefix=$LOCAL_LIB_DIR/hdf5-intel 2>&1 | tee hdf5_configure.log

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
    #export CC=mpiicc
    export CPPFLAGS="-I$LOCAL_LIB_DIR/hdf5-intel/include"
    export LDFLAGS=-L$LOCAL_LIB_DIR/hdf5-intel/lib
    ./configure \
      --enable-netcdf4 \
      --disable-dap \
      --prefix=$LOCAL_LIB_DIR/netcdf-intel 2>&1 | tee netcdf_configure.log

    make all -j $N 2>&1 | tee netcdf_compile.log
    make install 2>&1 | tee netcdf_install.log
}


build_proj4 () {

    # download and build PROJ.4
    mkdir -p $LOCAL_LIB_DIR/sources/proj.4
    cd $LOCAL_LIB_DIR/sources/proj.4

    git clone --depth 1 -b 4.9.2-maintenance https://github.com/OSGeo/proj.4.git . || git pull

    # remove and re-generate files created by autoconf
    autoreconf --force --install
    ./configure --prefix=$LOCAL_LIB_DIR/proj4-4.9.2

    make all
    make install
}

build_udunits() {

    # download and build UDUNITS
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    version=2.2.24
    url=ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-${version}.tar.gz

    wget -nc ${url}
    tar xzvf udunits-${version}.tar.gz

    cd udunits-${version}

    ./configure \
      --prefix=$LOCAL_LIB_DIR/udunits-intel 2>&1 | tee udunits_configure.log

    make all -j $N 2>&1 | tee udunits_compile.log
    make install 2>&1 | tee udunits_install.log

}

build_gsl() {

    # download and build GSL
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    version=2.3
    url=ftp://ftp.gnu.org/gnu/gsl/gsl-${version}.tar.gz

    wget -nc ${url}
    tar xzvf gsl-${version}.tar.gz

    cd gsl-${version}

    ./configure \
      --prefix=$LOCAL_LIB_DIR/gsl-intel 2>&1 | tee gsl_configure.log

    make all -j $N 2>&1 | tee gsl_compile.log
    make install 2>&1 | tee gsl_install.log

}

build_fftw() {

    # download and build FFTW
    mkdir -p $LOCAL_LIB_DIR/sources
    cd $LOCAL_LIB_DIR/sources

    version=3.3.6-pl2
    url=ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz

    wget -nc ${url}
    tar xzvf fftw-${version}.tar.gz

    cd fftw-${version}

    ./configure \
      --prefix=$LOCAL_LIB_DIR/fftw-intel \
      --with-pic \
      --enable-mpi \
      CC=$CC MPICC=$CC 2>&1 | tee fftw_configure.log

    make -j $N 2>&1 | tee fftw_compile.log
    make install 2>&1 | tee fftw_install.log

}


build_petsc() {

    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR


    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git . || git pull

    # Note: we use Intel compilers, disable Fortran, use 64-bit
    # indices, shared libraries, and debugging.
    ./config/configure.py \
        --with-cc=mpiicc --with-cxx=mpiicpc --with-fc=0 \
        --with-mpi-lib=$MPI_LIBRARY \
        --with-mpi-include=$MPI_INCLUDE \
        --with-blas-lapack-dir="$MKLROOT/lib/intel64" \
        --with-64-bit-indices=1 \
        --known-mpi-shared-libraries=1 \
        --with-debugging=1 \
        --with-valgrind=1 \
        --with-valgrind-dir=$VGROOT \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1 \
        --with-mpiexec="srun" \
          CFLAGS="$CFLAGS" \
          CXXFLAGS="$CXXFLAGS" 

          #--prefix=$PETSC_INSTALL_DIR

    #    COPTFLAGS="-g -O3 -ffast-math -march=bdver1 -fPIC" \
    #    FOPTFLAGS="-g -O3 -ffast-math -march=bdver1 -fPIC"


    # run conftest in an interactive job and wait for it to complete
    #srun -t 20 -n 1 -N 1 ./conftest-$PETSC_ARCH

    # run conftest in aa subitted job and wait for it to complete
    cat > conftest-slurm.sh <<EOF
#!/bin/bash
#SBATCH --qos=short
#SBATCH --job-name=petsc_config
#SBATCH --account=ice
#SBATCH --output=./petsc_config-%j.out
#SBATCH --error=./petsc_config-%j.err
#SBATCH --ntasks=16
#SBATCH --tasks-per-node=16
#SBATCH --profile=energy
#SBATCH --acctg-freq=energy=5
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=albrecht@pik-potsdam.de

cd $PETSC_DIR
srun -n 1 ./conftest-$PETSC_ARCH
EOF

    sbatch ./conftest-slurm.sh

    read -p "Wait for the job to complete and press RETURN."

    ./reconfigure-$PETSC_ARCH.py

    make all test
}

build_petsc4py() {

    module load anaconda/2.3.0
    # create a new virtual environment, with numpy already installed
    #conda create --name python_for_pism_calib numpy
    source activate python_for_pism_calib
    #pip install cython
    #which python

    unset CFLAGS
    unset CXXFLAGS

    PETSC4PYPATH=$LOCAL_LIB_DIR/petsc4py
    rm -rf $PETSC4PYPATH
    mkdir -p $PETSC4PYPATH
    cd $PETSC4PYPATH
    git clone https://bitbucket.org/petsc/petsc4py.git .
    cd $PETSC4PYPATH
    python setup.py build
    python setup.py install
}


build_pism() {
    set -e
    set -x
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    #mkdir -p $LOCAL_LIB_DIR/sources
    #cd $LOCAL_LIB_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    rm -rf build
    mkdir -p build
    cd build

    # use Intel's C and C++ compilers
    export PATH=$LOCAL_LIB_DIR/fftw-intel/lib/:$LOCAL_LIB_DIR/fftw-intel/include/:$PATH
    export PATH=$LOCAL_LIB_DIR/gsl-intel/lib/:$LOCAL_LIB_DIR/gsl-intel/include/:$PATH
    export PATH=$LOCAL_LIB_DIR/udunits-intel/lib/:$LOCAL_LIB_DIR/udunits-intel/include/:$PATH
    export PATH=$LOCAL_LIB_DIR/doxygen/bin/:$PATH
    export PATH=/p/system/packages/hdf5/1.8.18/impi/lib/:$PATH

    cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
          -DCMAKE_C_FLAGS="$CFLAGS" \
          -DCMAKE_CXX_COMPILER=mpiicpc \
          -DCMAKE_C_COMPILER=mpiicc  \
          -DPETSC_EXECUTABLE_RUNS=ON \
          -DMPI_C_DIR="$MPI_DIR" \
          -DPism_USE_JANSSON=NO \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PARALLEL_HDF5=ON \
          -DPism_USE_PROJ4=YES \
          -DPism_BUILD_EXTRA_EXECS:BOOL=OFF \
          $PISM_DIR/sources
    make -j $N install
    set +x
    set +e

 #          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR/hdf5;$LOCAL_LIB_DIR/netcdf" \
 #          -DMPI_C_INCLUDE_PATH="$MPI_INCLUDE" \
 #          -DMPI_C_LIBRARIES="$MPI_LIBRARY" \

}

build_all() {

    build_hdf5      # or: module load hdf5/1.8.18/intel/parallel
    build_netcdf    # or: module load netcdf-c/4.4.1.1/intel/parallel
    #build_nco      # module load nco/4.5.0

    build_petsc	    # or: petsc/3.7.5
    #build_petsc4py	# not working yet
    build_udunits   # or: module load udunits/2.2.19 
    build_gsl       # or: module load gsl/1.16
    build_fftw      # or: module load fftw/3.3.4
    build_proj4	    # or: module load proj4/4.9.3

    build_pism
}
