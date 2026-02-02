#!/bin/bash

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

echo 'working directory ='
echo $PWD

echo 'swif_job_work_dir='$SWIF_JOB_WORK_DIR

# source login stuff since swif2 completely nukes any sensible default software environment
#source /home/puckett/.cshrc
#source /home/puckett/.login

#echo 'before sourcing environment, env = '
#env 

#module load gcc/9.2.0

#!/bin/bash 

MODULES=/etc/profile.d/modules.sh 

if [[ $(type -t module) != function && -r ${MODULES} ]]; then 
source ${MODULES} 
fi 

module purge
    
if [ -d /apps/modulefiles ]; then 
    module use /apps/modulefiles 
fi 

module load gcc/9.2.0 

source /site/12gev_phys/softenv.sh 2.4

ldd /work/halla/sbs/ANALYZER/install/bin/analyzer |& grep not

#source /etc/profile.d/modules.sh

#module load gcc/9.2.0


#export ROOTSYS=/site/12gev_phys/2.5/Linux_CentOS7.7.1908-gcc9.2.0/root/6.24.06

#source $ROOTSYS/bin/thisroot.sh

#echo 'after attempting to source environment, env = '
#env
#source /work/halla/sbs/puckett/install/bin/g4sbs.sh 
#cd /work/halla/sbs/puckett/GMN_ANALYSIS

#cd /scratch/slurm/puckett

#root -b -q 'GEP_FOM_quick_and_dirty.C+("setup_GEP_FOM_option1_67cm.txt","GEP_FOM_option1_67cm_take2.root")' >output_GEP_FOM_option1_67cm_take2.txt

#root -b -q 'GEM_reconstruct_standalone_consolidated.C+("../UVA_EEL_DATA/gem_hit_2811*.root","config_UVA_EEL_5layer_Jan2021.txt", "temp2811_gainmatch.root")' >output2811_gainmatch.txt

# setup environment for ANALYZER and SBS-offline:

echo 'working directory = '$PWD

export ANALYZER=/work/halla/sbs/ANALYZER/install
source $ANALYZER/bin/setup.sh
source /work/halla/sbs/SBS_OFFLINE/install/bin/sbsenv.sh
#source /work/halla/sbs/pdbforce/SBSOFFLINE/install/bin/sbsenv.sh

#cp $SBS/run_replay_here/.rootrc $PWD

#mkdir -p $PWD/in
#mkdir -p $PWD/rootfiles
#mkdir -p $PWD/logs

export BBCAL_REPLAY=/w/halla-scshelf2102/sbs/pdbforce/BBCal_replay
export CONFIG_DIR=$BBCAL_REPLAY/macros/Combined_macros/cfg
export GAIN_DIR=$BBCAL_REPLAY/macros/Gain
export HIST_DIR=$BBCAL_REPLAY/macros/hist
export RunList_DIR=$BBCAL_REPLAY/macros/Run_list

# setenv BBCAL_REPLAY /w/halla-scshelf2102/sbs/pdbforce/BBCal_replay
# setenv CONFIG_DIR $BBCAL_REPLAY/macros/Combined_macros/cfg
# setenv GAIN_DIR $BBCAL_REPLAY/macros/Gain
# setenv HIST_DIR $BBCAL_REPLAY/macros/hist
# setenv RunList_DIR $BBCAL_REPLAY/macros/Run_list

export OUT_DIR=$SWIF_JOB_WORK_DIR
export LOG_DIR=$SWIF_JOB_WORK_DIR

echo 'OUT_DIR='$OUT_DIR
echo 'LOG_DIR='$LOG_DIR
# try this under swif2:
#export DATA_DIR=$PWD
#export OUT_DIR=/volatile/halla/sbs/puckett/GMN_REPLAYS/SBS1_OPTICS/rootfiles
#export LOG_DIR=/volatile/halla/sbs/puckett/GMN_REPLAYS/SBS1_OPTICS/logs
#mkdir -p /volatile/halla/sbs/puckett/GMN_REPLAYS/rootfiles
#mkdir -p /volatile/halla/sbs/puckett/GMN_REPLAYS/logs

#export OUT_DIR=/volatile/halla/sbs/puckett/GMN_REPLAYS/SBS4/rootfiles
#export LOG_DIR=/volatile/halla/sbs/puckett/GMN_REPLAYS/SBS4/rootfiles
export ANALYZER_CONFIGPATH=$SBS_REPLAY/replay
# ------
#export ANALYZER_CONFIGPATH=$PDBFORCE_REPLAY/replay
# ------

setnum=$1
iter=$2
configfile=$3

cp $BBCAL_REPLAY/macros/.rootrc $SWIF_JOB_WORK_DIR

# analyzer -b -q 'replay_gmn.C+('$runnum','$maxevents','$firstevent','\"$prefix\"','$firstsegment','$maxsegments')'

analyzer -b -q 'test_eng_cal_BBCal.C('\"$CONFIG_DIR/$3\"','$iter')'

outfile1=$OUT_DIR'/eng_cal_gainCoeff_sh_'$setnum'_'$iter'.txt'
outfile2=$OUT_DIR'/eng_cal_gainRatio_sh_'$setnum'_'$iter'.txt'
outfile3=$OUT_DIR'/eng_cal_gainCoeff_ps_'$setnum'_'$iter'.txt'
outfile4=$OUT_DIR'/eng_cal_gainRatio_ps_'$setnum'_'$iter'.txt'
outhist=$OUT_DIR'/eng_cal_BBCal_'$setnum'_'$iter'.root'

mv $outfile1 $GAIN_DIR
mv $outfile2 $GAIN_DIR
mv $outfile3 $GAIN_DIR
mv $outfile4 $GAIN_DIR
mv $outhist $HIST_DIR

