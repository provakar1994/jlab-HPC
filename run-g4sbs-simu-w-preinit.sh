#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs g4sbs simulation jobs.                                   #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 11-09-2022                           #
# ---------                                                                 #
# Original file from P. Datta                                               #
# MODIFIED by E. Fuchey <efuchey@jlab.org> on 2023/10/02                    #
# to accomodate *true* preinitialization file scripts/                      #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script above.  #
# ------------------------------------------------------------------------- #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

# list of arguments
macro=$1
preinit=$2
postscript=$3
nevents=$4
outfilebase=$5
outdirpath=$6
run_on_ifarm=$7
g4sbsenv=$8
ANAVER=$9      # Analyzer version
useJLABENV=${10}  # Use 12gev_env instead of modulefiles?
JLABENV=${11}  # /site/12gev_phys/softenv.sh version

# paths to necessary libraries (ONLY User specific part) ---- #
export G4SBS=$g4sbsenv
# ----------------------------------------------------------- #

ifarmworkdir=${PWD}
if [[ $run_on_ifarm == 1 ]]; then
    SWIF_JOB_WORK_DIR=$ifarmworkdir
    echo -e "Running all jobs on ifarm!"
fi
echo -e 'Work directory = '$SWIF_JOB_WORK_DIR

# Enabling module
MODULES=/etc/profile.d/modules.sh 
if [[ $(type -t module) != function && -r ${MODULES} ]]; then 
    source ${MODULES} 
fi 
# Choosing software environment
if [[ (! -d /group/halla/modulefiles) || ($useJLABENV -eq 1) ]]; then 
    source /site/12gev_phys/softenv.sh $JLABENV
else 
    module use /group/halla/modulefiles
    module load analyzer/$ANAVER
    module list
fi

# Setup g4sbs specific environments
source $G4SBS/bin/g4sbs.sh

# creating post script
cp $G4SBS'/script/'${macro}'.mac' $postscript
echo '/g4sbs/filename '$outfilebase'.root' >>$postscript
echo '/g4sbs/run '$nevents >>$postscript
#cat $postscript

g4sbs --pre=$preinit'.mac' --post=$postscript 

# idiot proofing
if [[ ! -d $outdirpath ]]; then
    mkdir $outdirpath
fi
mv $outfilebase'.root' $outdirpath
mv $outfilebase'.csv' $outdirpath

# clean up the work directory
rm $postscript
