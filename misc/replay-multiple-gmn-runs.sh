#!/bin/bash

## --------
## This script can be used to automate submiting replay jobs for 
## multiple runs with multiple segments.
## --------
## P. Datta <pdbforce@jlab.org> CREATED 06/16/23

export SCRIPT_DIR=/w/halla-scshelf2102/sbs/pdbforce/jlab-HPC

# defining arrays of run numbers and segments
# rnums=(11449 11451 11452 11456 11493 11494 11495 11496 11551 11554)
# nsegs=(33 30 106 175 42 61 61 54 28 18)
rnums=(11436 11500 11547)
nsegs=(63 61 76)

index=0
for i in ${rnums[@]}; do
    #echo -e $i " segs " ${nsegs[$index]}
    yes | $SCRIPT_DIR/submit-gmn-jobs.sh $i -1 ${nsegs[$index]} 0
    index=$((index+1))
done
