#!/bin/bash

## --------
## This script can be used to automate submiting replay jobs for 
## multiple runs with multiple segments to JLab farm in the batch mode.
## --------
## P. Datta <pdbforce@jlab.org> CREATED 06/16/23

## ** ATTENTION!! Read the instructions below before execution.
## 1. Either copy modified ../setenv.sh file to the current directory
##    (ie jlab-HPC/misc) before executing this script, or,
##    execute this script from jlab-HPC directory.
## 2. It is mandatory to set the "workflowname" and "outdirpath" variables
##    properly in the submit-gmn-jobs.sh script, before executing this script.
## ----
source setenv.sh

# defining arrays of run numbers and segments
# Eg: use following arrays to replay all the SBS4-SBS50% LH2 runs:
# -------------------------
# rnums=(11589 11590 11592)
# nsegs=(14 73 27)
# -------------------------
rnums=(13503 13793)
nsegs=(151 98)

index=0
for i in ${rnums[@]}; do
    #echo -e $i " segs " ${nsegs[$index]}
    yes | $SCRIPT_DIR/submit-gmn-jobs.sh $i -1 ${nsegs[$index]} 0
    index=$((index+1))
done
