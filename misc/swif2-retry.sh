#!/bin/bash

## -----------
## This is a convenience script to retry jobs for a given
## swif2 workflow.
## --------
## P. Datta <pdbforce@jlab.org> CREATED 02/16/24

workflowname=$1

swif2 run $workflowname
swif2 retry-jobs $workflowname -problem SLURM_NODE_FAIL
swif2 retry-jobs $workflowname -problem SLURM_FAILED
