#!/bin/bash

# Define the output file path
outfile="../jlab_HPC_local_environment.txt"

# Check if the file already exists and remove it
if [[ -e $outfile ]]; then
    rm $outfile
fi

# Add some lines to describe the outfile
echo "#Configuration file for jlab-HPC. setenv.sh will reference this file when executing any shell scripts." >> $outfile

# Define the static variable names
declare -a varnames=("workflowname" "outdirpath" "SCRIPT_DIR" "G4SBS" "SIMC" "LIBSBSDIG" "SBSOFFLINE" "SBS_REPLAY")

# Loop to collect values for the static variable names
for varname in "${varnames[@]}"; do
    # Prompt for the value of the current variable
    read -p "Enter valid path for $varname: " varvalue

    # Write to the output file
    echo "$varname = $varvalue" >> $outfile
done

echo "Variables saved to $outfile"
