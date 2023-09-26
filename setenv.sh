#!/bin/bash

# Define the input file path
infile="../jlab_HPC_local_environment.txt"

# Define static analyzer variable
ANAVER='1.7.4'  # Analyzer version

# Check if the file exists
if [[ ! -e $infile ]]; then
    echo "File $infile not found! Run setup.sh once before use."
    exit 1
fi

# Read the file line by line
while IFS=" = " read -r varname varvalue
do
    # Check if the line starts with a "#", and if so, skip it
    if [[ $varname =~ ^# ]]; then
        continue
    fi

    # If the variable name is 'outdirpath', set only a local shell variable
    if [[ $varname == "outdirpath" ]]; then
        declare $varname="$varvalue"
        echo "Set local variable $varname=$varvalue"
        continue
    fi

    # If the variable name is 'workflowname', set only a local shell variable
    if [[ $varname == "workflowname" ]]; then
        declare $varname="$varvalue"
        echo "Set local variable $varname=$varvalue"
        continue
    fi

    # Export the variable
    export "$varname=$varvalue"
    echo "Exported $varname=$varvalue"
done < "$infile"

# Path to data directories (NOT User Specific)
export ANALYZER=/u/group/halla/apps/analyzer/1.7.4/gcc12/RelWithDebInfo
# The path is written this way below becauses strings will need
# to be added to the left side of them, ie /cache/$GMN_DATA_PATH
export GMN_DATA_PATH=halla/sbs/raw
export GEN_DATA_PATH=halla/sbs/GEnII/raw
