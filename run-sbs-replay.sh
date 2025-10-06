#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs real data replay jobs for GMn/nTPE data. It was created  #
# based on Andrew Puckett's script.                                         #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 11-09-2022                           #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script above.  #
# ------------------------------------------------------------------------- #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

# List of arguments
runnum=$3
maxevents=$4
firstevent=$5
prefix=$6
firstsegment=$7
maxsegments=$8
use_sbs_gems=$9
datadir=${10}
outdirpath=${11}
run_on_ifarm=${12}
analyzerenv=${13}
sbsofflineenv=${14}
sbsreplayenv=${15}
ANAVER=${16}        # Analyzer version
useJLABENV=${17}    # Use 12gev_env instead of modulefiles?
JLABENV=${18}       # /site/12gev_phys/softenv.sh version
maxstream=$2
firststream=$1

# paths to necessary libraries (ONLY User specific part) ---- #
export ANALYZER=$analyzerenv
export SBSOFFLINE=$sbsofflineenv
export SBS_REPLAY=$sbsreplayenv
export DATA_DIR=$datadir
# ----------------------------------------------------------- #

ifarmworkdir=${PWD}
if [[ $run_on_ifarm == 1 ]]; then
    SWIF_JOB_WORK_DIR=$ifarmworkdir
fi
echo 'Work directory = '$SWIF_JOB_WORK_DIR

# Enabling module
MODULES=/etc/profile.d/modules.sh 
if [[ $(type -t module) != function && -r ${MODULES} ]]; then 
    source ${MODULES} 
fi 
# Choosing software environment
if [[ (! -d /group/halla/modulefiles) || ($useJLABENV -eq 1) ]]; then 
    source /site/12gev_phys/softenv.sh $JLABENV
    source $ANALYZER/bin/setup.sh
else 
    module use /group/halla/modulefiles
    module load analyzer/$ANAVER
    module list
fi

# setup analyzer specific environments
export ANALYZER_CONFIGPATH=$SBS_REPLAY/replay
source $SBSOFFLINE/bin/sbsenv.sh

export DB_DIR=$SBS_REPLAY/DB
export OUT_DIR=$SWIF_JOB_WORK_DIR
export LOG_DIR=$SWIF_JOB_WORK_DIR

echo 'DB_DIR='$DB_DIR
echo 'OUT_DIR='$OUT_DIR
echo 'LOG_DIR='$LOG_DIR

# handling any existing .rootrc file in the work directory
# mainly necessary while running the jobs on ifarm
if [[ -f .rootrc ]]; then
    mv .rootrc .rootrc_temp
fi
cp $SBS/run_replay_here/.rootrc $SWIF_JOB_WORK_DIR

if [ $prefix = 'e1209019' ] #GMN replay
then
    analyzer -b -q 'replay_gmn.C+('$runnum','$maxevents','$firstevent','\"$prefix\"','$firstsegment','$maxsegments')'
fi

if [ $prefix = 'e1209016' ] #GEN replay
then
    analyzer -b -q 'replay_gen.C+('$runnum','$maxevents','$firstevent','\"$prefix\"','$firstsegment','$maxsegments',2,0,0,'$use_sbs_gems')'
fi

if [ $prefix = 'gep5' ] #GEP replay #Hard-coded for 3-stream.
then
    analyzer -b -q 'replay_gep.C+('$runnum','$maxevents','$firstevent','\"$prefix\"','$firstsegment','$maxsegments','$maxstream',0,0,'$firststream','$use_sbs_gems',1)'
fi

outfilename=$OUT_DIR'/'$prefix'_*'$runnum'*.root'
logfilename=$LOG_DIR'/'$prefix'_*'$runnum'*.log' 

# move output files
mv $outfilename $outdirpath/rootfiles
mv $logfilename $outdirpath/logs

# clean up the work directory
rm .rootrc
if [[ -f .rootrc_temp ]]; then
    mv .rootrc_temp .rootrc
fi
