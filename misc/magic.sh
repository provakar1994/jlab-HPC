#!/bin/bash

for i in {1..5}
#for i in {1..1}
do
    sleep 3600
    echo "Iteration $i"
    swif2-retry.sh sbs7-qe-simc
    #swif2-retry.sh sbs7-inel-take2
    swif2-retry.sh sbs14-qe-simc
    #swif2-retry.sh sbs14-inel
    swif2-retry.sh sbs4-inel
    swif2-retry.sh sbs11-inel-take2
done

