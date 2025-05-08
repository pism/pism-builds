#!/bin/bash

echo RUNNING INTEL COMPILER BUILD FLAG TESTS

module purge
module load pism/stable1.0
module list

# Submit this with:
# sbatch --ntasks=32 --tasks-per-node=16 --exclusive --qos=medium --job-name=pism_opt_flags --partition=broadwell --mail-type=END,FAIL --mail-user=albrecht@pik-potsdam.de --account=ice run_opt_flags.sh

#source $PETSC_BUILD_DIR/profile
export LOCAL_LIB_DIR=$HOME/software
export BUILD_DIR=$LOCAL_LIB_DIR/hpc-builds/nextscale

count=1
start=`date +%s`
startnew=$start


optprec='-fp-model=precise '
for optlev in '-no-fast-transcendentals ' '-O3 ' '-O2 ' '-Os ' '-Ofast ' ; do
    for archlev in '' '-axCORE-AVX2 ' '-xHost ' ; do
        for tunelev in '' '-mtune=broadwell ' '-mtune=haswell ' ; do

                        count=$((count+1))
                        echo $count

                        #export CFLAGS="$useipo $usemkl $optlev $archlev $tunelev $proflev"
                        export CFLAGS="$optprec$optlev$archlev$tunelev"
                        export CXXFLAGS=$CFLAGS
                        export FFLAGS=$CFLAGS
                        
                        # PUT YOUR BUILD CODE HERE, you may also decied to build PETSc and PISM together, so they are both bette
                        echo FLAGS: $CFLAGS
                        echo LOCAL_LIB_DIR: $LOCAL_LIB_DIR
                        echo PETSC_DIR: $PETSC_DIR

                        #PETSc and PISM build ##############################################################
                        cd BUILD_DIR
                        bash build_all.sh
                        end1=`date +%s`
                        runtime1=$((end1-startnew))
                        echo "$count build $runtime1 s" >> test_results.out

                        ################################################################################
                        #PISM test run

                        rm -rf $BUILD_DIR/test
                        mkdir -p $BUILD_DIR/test
                        cd $BUILD_DIR/test
 
                        # RUN YOUR BENCHMARKS HERE using $PISM_DIR/bin/pismr
                        bash run_pism_test.sh

                        end3=`date +%s`
                        runtime=$((end3-startnew))
                        startnew=$end3
                        echo "$count : $(($runtime / 60)) minutes and $(($runtime % 60)) seconds elapsed." >> test_results.out


                        ################################################################################
                        # get performance measure ##########################################################
                        echo $CFLAGS >> test_results.out
                        /p/system/packages/anaconda/2.3.0/bin/ncdump -h $PISM_TEST_DIR/results/beddef_lc_${count}_resf.nc | grep 'run_stats:model_years_per_processor_hour' >> test_results.out
                        echo " " >> test_results.out

        done
    done
done

end=`date +%s`
runtime=$((end-start))
echo "$runtime s for all experiments" >> $PISM_TEST_DIR/submission/run_results.sh
echo
#sacct --user=albrecht --parsable2 -S2018-03-25 --format="jobid,jobname,partition,state,start,end,maxvmsize,maxvmsizenode,maxvmsizetask,avevmsize,maxrss,maxrssnode,maxrsstask,averss,maxpages,maxpagesnode,maxpagestask,avepages,mincpu,mincpunode,mincputask,avecpu,ntasks,alloccpus,elapsed,exitcode,maxdiskread,maxdiskreadnode,maxdiskreadtask,avediskread,maxdiskwrite,maxdiskwritenode,maxdiskwritetask,avediskwrite,avecpufreq,reqcpufreqmin,reqcpufreqmax,reqcpufreqgov" | grep "ID" >> run_results.sh
