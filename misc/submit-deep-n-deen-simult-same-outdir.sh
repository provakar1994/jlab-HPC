#!/bin/bash

## -----------
## This script submits simc deep & deen jobs simultaneously.
## NOTE:
## 1. SIMC & g4sbs input file names will have to be the same
##    expect for deep/deen part.
## 2. outdirpath will have to be the same.
## 3. workflowname will have to be the same.
## --------
## P. Datta <pdbforce@jlab.org> CREATED 06/16/23

export SCRIPT_DIR=/w/halla-scshelf2102/sbs/pdbforce/jlab-HPC

# arguments
infilebase=$1   # SIMC input file name w/o deep/deen part 
sbsconfig=$2    # SBS configuration (Valid options: 4,7,11,14,8,9)
# No. of jobs to submit (NOTE: # events to generate per job get set by SIMC infile ("ngen" flag))
fjobid=$3       # first job id
njobs=$4        # total no. of jobs to submit 
run_on_ifarm=$5 # 1=>Yes (If true, runs all jobs on ifarm)

echo -e "Submiting deep jobs.."
#yes | $SCRIPT_DIR/submit-simc-g4sbs-digi-replay-jobs.sh $infilebase'_deep' $sbsconfig $fjobid $njobs $run_on_ifarm

echo -e "Submiting deen jobs.."
#yes | $SCRIPT_DIR/submit-simc-g4sbs-digi-replay-jobs.sh $infilebase'_deen' $sbsconfig $fjobid $njobs $run_on_ifarm
